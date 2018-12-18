# Driverless AI Mojo Rest Server

This will deploy a rest server for Driverless AI mojos

## Parameters:

The following are the parameters that can be supplied to deploy the cluster:
  - `--name` -- [REQUIRED] Name of the deployment
  - `-namespace` [OPTIONAL] Namespace where the deployment will be deployed e.g. prod, staging, <my_namespace>, etc.
  - `--memory` [OPTIONAL] Amount of memory each pod in the deployment. Default is 1Gi, NOTE: only input the numeric value. If you want less then 1Gi use decimals (e.g. 0.5)
  - `--cpu` [OPTIONAL] Number of cpus in each deployment pod
  - `--pvc_name` [REQUIRED] name of persistent volume claim, name of an existent pvc
  - `--mojo_location` [REQUIRED] location where mojo resides.
  - `--license_location` [REQUIRED] location where license.sig file exists in pod
  - `--model_server_image` [REQUIRED] Docker image used to launch each pod

NOTE: for `license_location` and `mojo_location` it is recommended to store them in `/mojo-models` which is the mount path for the persistent volume bound to the persistent volume claim
EXAMPLE `--license_location=/mojo-models/license.sig`

## Quickstart:
```
ks init <my_ksonnet_app_name>
cd <my_ksonnet_app_name>

ks env add <my_environment_name>
ks registry add h2o-kubeflow <this_repository/h2o-kubeflow>
ks pkg install h2o-kubeflow/h2o3-static

ks prototype use io.ksonnet.pkg.mojo-serving mojo-serving \
--name mojo-serving \
--namespace kubeflow \
--memory 1 \
--cpu 1 \
--pvc_name driverless \
--mojo_location /mojo-models/mojo.zip \
--license_location /mojo-models/license.sig \
--model_server_image <docker_image_of_h2o3>
```
