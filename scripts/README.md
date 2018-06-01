#### Burst to Cloud

If you are interested in additional orchestration, follow the following steps to setup a Kubernetes cluster. This walkthrough will setup a Kubernetes cluster with the ability to scale with the demand of additional resources.

Note: This is a prototype and will continue to be changed/modified as time progresses.

1. Start a machine with Ubuntu 16.04. This can be On-Premise or in the cloud
2. Copy all the scripts from the [scripts](https://github.com/h2oai/h2o-kubeflow/tree/master/scripts) folder in this repo to the machine
3. Move `deployment-status.service` and `deployment-status.timer` to `/etc/systemd/system/` and enable the services.
 ```
 sudo mv deployment-status.service /etc/systemd/system/
 sudo mv deployment-status.timer /etc/systemd/system/
 sudo systemctl enable deployment-status.service deployment-status.timer
 sudo systemctl start deployment-status.service deployment-status.timer
 ```
4. Move `deployment-status.sh`, `k8s_master_setup.sh` and `k8s_slave_setup.sh` to a new directory `/opt/kubeflow/`
```
sudo mkdir /opt/kubeflow
sudo mv k8s_master_setup.sh /opt/kubeflow/
```
5. Run `sudo /opt/kubeflow/k8s_master_setup.sh`. This script will modify `k8s_slave_setup.sh` with the necessary commands to connect any other machines __Ubuntu 16.04__ to the Kubernetes cluster
6. Run the new `k8s_slave_setup.sh` on any other machines you want to connect to the cluster
7. `k8s_slave_setup.sh` will also create a new file called config.txt in `/opt/kubeflow/` modify the final line `KSONNET_APP` to include the relative file path to the file created by `ks init`: /home/ubuntu/my_ksonnet_app --> use `KSONNET_APP=my_ksonnet_app`
8. Use `kubectl get nodes` to ensure that all nodes are attached properly to the cluster
9. Follow above steps to deploy H2O on Kubeflow + Kubernetes
