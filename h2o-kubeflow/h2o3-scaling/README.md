# Static H2O-3 Cluster

This will deploy automatically scaling H2O-3 Cluster. This is currently in development and is not 100% stable.

## Requirements:

for the horizontal pod autoscaler to work, you will need to deploy this to your Kubernetes cluster first:
https://github.com/kubernetes-incubator/metrics-server

1. Clone the repo above to your local machine
2. Once kubectl is properly configured, run `kubectl create -f deploy/1.8+/` from the top of the cloned repo

this will launch the metrics api server that the horizontal pod autoscaler calls for memory/cpu consumption

## NEED TO KNOW
  1. H2O-3 locks its cluster once it starts running jobs. If the memory consumption threshold, the horizontal pod autoscaler will spawn a new pod, but the pod will not be able to attach to the cluster. The cluster will need to be shutdown and re-initialized.
    - Python restart commands `h2o.cluster().shutdown()` and `h2o.init()`
  2. Due to the nature of how scaling is applied, it is recommended that jobs be run as a script where the cluster will be shutdown automatically if a new node is spawned.
  3. New pods are spawned one at a time, and as a result high cost could be incurred if it takes multiple iterations to reach a suitable number of pods.
  4. Once the amount of jobs is reduced, the horizontal pod autoscaler will down scale automatically as well to fit the memory consumption.

## Parameters:

The following are the parameters that can be supplied to deploy the cluster:
  - `--name` -- [REQUIRED] Name of the deployment
  - `-namespace` [OPTIONAL] Namespace where the deployment will be deployed e.g. prod, staging, <my_namespace>, etc.
  - `--memory` [OPTIONAL] Amount of memory each pod in the deployment and node in H2O-3 Cluster will get. Default is 1Gi, NOTE: only input the numeric value. If you want less then 1Gi use decimals (e.g. 0.5)
  - `--cpu` [OPTIONAL] Number of cpus in each deployment pod and H2O-3 node
  - `--model_server_image` [REQUIRED] Docker image used to launch each pod

## Quickstart:
```
ks init <my_ksonnet_app_name>
cd <my_ksonnet_app_name>

ks env add <my_environment_name>
ks registry add h2o-kubeflow <this_repository/h2o-kubeflow>
ks pkg install h2o-kubeflow/h2o3-scaling

ks prototype use io.ksonnet.pkg.h2o3-scaling h2o3-scaling \
--name h2o3-scaling \
--namespace kubeflow \
--memory 1 \
--cpu 1 \
--replicas 2 \
--model_server_image <docker_image_of_h2o3>
```
