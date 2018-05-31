#!/bin/bash

# Check for pending deployments/pods
# If any are pending because of insufficient resources, Kill the deployment
if $(kubectl get pods -o wide | grep -q "Pending")
then
  if $(kubectl get pods --output="jsonpath={.items[*].status.conditions[*].message}" | grep -q "Insufficient")
  then
    echo "there are unscheduled pods due to lack of resources"
    (IFS=$'\n'
    for x in $(kubectl get deployments)
    do
      header="NAME"
      deployname=$(echo $x | awk '{ print $1 }')
      desired=$(echo $x | awk '{ print $2 }')
      available=$(echo $x | awk '{ print $5 }')
      if [ $deployname == $header ]
      then
        echo "HEADER NOTHING TO DO"
      else
        if [ $desired == $available ]
        then
          echo $deployname
          echo "Healthy Cluster"
        else
          echo $deployname
          echo "Unhealthy Cluster, Killing Deployment"
          namespace=$(kubectl get deployment $deployname --output="jsonpath={ .metadata.namespace}")
          kubectl delete deployment $deployname -n $namespace
          echo "Requesting New Node"
          sudo sed -i "s/^REQUEST_NEW_NODE=.*/REQUEST_NEW_NODE=TRUE/g" /opt/kubeflow/config.txt
          touch /home/ubuntu/tmpvars.txt
          sudo cat > /home/ubuntu/tmpvars.txt << EOF
Deployment=$deployname
Namespace=$namespace
EOF
        fi
      fi
    done
    )
  else
    echo "something else is wrong"
  fi
else
  echo "no pending pods"
fi

# check if the cluster is allowed to expand. If it is, start a new instance
burst=$(sudo cat /opt/kubeflow/config.txt | grep "ALLOW_BURST_TO_CLOUD" | sed "s/^ALLOW_BURST_TO_CLOUD=//g")
cloudinstance=$(sudo cat /opt/kubeflow/config.txt | grep "CLOUD_INSTANCES" | sed "s/^CLOUD_INSTANCES=//g")
ksapp=$(sudo cat /opt/kubeflow/config.txt | grep "KSONNET_APP" | sed "s/^KSONNET_APP=//g")
requestnewnode=$(sudo cat /opt/kubeflow/config.txt | grep "REQUEST_NEW_NODE" | sed "s/^REQUEST_NEW_NODE=//g")
deployname=$(sudo cat /home/ubuntu/tmpvars.txt | grep "Deployment" | sed "s/^Deployment=//g")
namespace=$(sudo cat /home/ubuntu/tmpvars.txt | grep "Namespace" | sed "s/^Namespace=//g")

if [ $burst == "TRUE" ] && [ $requestnewnode == "TRUE" ]
then
  echo "CREATING NEW NODE: ALLOW_BURST_TO_CLOUD=TRUE"
  gcloud compute instances create kubeflow-burst-to-cloud-$cloudinstance \
  --machine-type n1-standard-8 \
  --boot-disk-size 128GB \
  --network default \
  --zone us-west1-b \
  --metadata-from-file startup-script=/opt/kubeflow/k8s_slave_setup.sh \
  --scopes cloud-platform \
  --image-family "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"

  # While loop to check if instance is up and ready to be modified
  isup="FALSE"
  while [ $isup == "FALSE" ]
  do
    currentstatus=$(gcloud compute instances describe kubeflow-burst-to-cloud-$cloudinstance --zone us-west1-b | grep "status" | sed "s/^status: //g")
    if [ $currentstatus == "RUNNING" ]
    then
      isup="TRUE"
      newcloudinstances=$(($cloudinstance+1))
      sudo sed -i "s/^CLOUD_INSTANCES=.*/CLOUD_INSTANCES=${newcloudinstances}/g" /opt/kubeflow/config.txt
    else
      echo "WAITING FOR INSTANCE TO START...."
    fi
    sleep 5
  done

  # While loop to check if node has been properly attached to cluster and ready to be used
  nodeready="FALSE"
  while [ $nodeready == "FALSE" ]
  do
    nodestatus=$(kubectl get nodes | grep "kubeflow-burst-to-cloud-$cloudinstance" | awk '{ print $2 }')
    if [ $nodestatus == "Ready" ]
    then
      cd /home/ubuntu/$ksapp
      ks apply $namespace -c $deployname
      rm /home/ubuntu/tmpvars.txt
      nodeready="TRUE"
    else
      echo "WAITING FOR NODE TO BE READY"
      sleep 5
    fi
  done
  sudo sed -i "s/^REQUEST_NEW_NODE=.*/REQUEST_NEW_NODE=FALSE/g" /opt/kubeflow/config.txt
else
  echo "DO NOTHING: BURST TO CLOUD NOT ENABLED or NO NEW NODE REQUESTED"
fi
