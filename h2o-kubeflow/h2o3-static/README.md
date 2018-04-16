# Static H2O-3 Cluster

This will deploy a static H2O-3 Cluster.

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
ks pkg install h2o-kubeflow/h2o3-static

ks prototype use io.ksonnet.pkg.h2o3-static h2o3-scaling \
--name h2o3-static \
--namespace kubeflow \
--memory 1 \
--cpu 1 \
--replicas 2 \
--model_server_image <docker_image_of_h2o3>
```
