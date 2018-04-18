[![Docker Repository on Quay](https://quay.io/repository/fjudith/h2o-kubeflow-notebook/status "Docker Repository on Quay")](https://quay.io/repository/fjudith/h2o-kubeflow-notebook)

# H2O + Kubeflow Integration

This is a project for the integration of H2O.ai and Kubeflow. The integration of H2O and Kubeflow is an extremely powerful opportunity, as it provides a turn-key solution for easily deployable and highly scalable machine learning applications, with minimal input required from the user.

#### Kubeflow
[Kubeflow](https://github.com/kubeflow/kubeflow) is an open source project managed by Google and built on top of their Kubernetes engine. It is designed to alleviate some of the more tedious tasks associated with machine learning. Kubeflow helps orchestrate deployment of apps through the full cycle of development, testing, and production, and allows for resource scaling as demand increases.

#### H2O 3
[H2O 3’s](http://docs.h2o.ai/h2o/latest-stable/h2o-docs/index.html) goal is to reduce the time spent by data scientists on time-consuming tasks like designing grid search algorithms and tuning hyperparameters, while also providing an interface that allows newer practitioners an easy foothold into the machine learning space.

#### Contents
This repository contains all the necessary components for deploying H2O 3 on Kubeflow

Dockerfiles:
- Dockerfile.h2o3 -- dockerfile to build a docker image of H2O 3. This image is a standard deployment of H2O 3, and is readily available [here](https://github.com/h2oai/h2o-3/blob/master/Dockerfile) as well.
- Dockerfile.h2o3notebook -- dockerfile to build the Kubeflow Jupyterhub Notebook with H2O 3 packages. This requires the following scripts:
  - jupyter_notebook_config.py
  - start-singleuser.sh
  - start-notebook.sh
  - start.sh

kubeflow:
- directories [driverless, h2o3-static, h2o3-scaling] contain the manifests required to deploy their corresponding applications. Please note, all Kubeflow components are available in the Kubeflow repository [here](https://github.com/kubeflow/kubeflow)
  - h2o3-static -- contains components for deploying a single or multinode H2O-3 cluster using Kubeflow. If more nodes are required, you will need to manually change the parameters and relaunch the cluster.
  - h2o3-scaling -- contains components for deploying an H2O-3 cluster that will automatically scale with memory demands. Read the README within the component folder for additional information and requirements.  
- registry.yaml -- manifest file that declares ksonnet packages available within the directory.


#### Quick Start
Complete steps to deploy Kubeflow can be found in their [User Guide](https://github.com/kubeflow/kubeflow/blob/master/user_guide.md)

You will also need [ksonnet](https://ksonnet.io) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) command line tools.

- Create a Kubernetes cluster. Either on-prem or on Google Cloud
- Run the following commands to setup your ksonnet app (how you deploy Kubeflow)

```bash
# create ksonnet app
ks init <my_ksonnet_app>
cd <my_ksonnet_app>

# add ksonnet registry to app containing all the kubeflow manifests as maintained by Google Kubeflow team
ks registry add kubeflow https://github.com/kubeflow/kubeflow/tree/master/kubeflow
# add ksonnet registry to app containing all the h2o component manifests
ks registry add h2o-kubeflow <this_github_repo/h2o-kubeflow>
ks pkg install kubeflow/core
ks pkg install kubeflow/tf-serving
ks pkg install kubeflow/tf-job
ks pkg install h2o-kubeflow/h2o3-static

# deploy core Kubeflow componentes
kubectl create namespace kubeflow
ks generate core kubeflow-core --name=kubeflow-core --namespace=kubeflow
ks env add <my_environment_name>

# skip this line if not on cloud deployment of Kubernetes
ks param set kubeflow-core cloud gke --env=cloud

ks apply <my_environment_name> -c kubeflow-core
```

- Deploy H2O 3 by running the following commands. <location_of_docker_image> is probably a Google Container Repository with the format `gcr.io/<my_project>/<h2o3_image>:version`:
  - NOTE:
    - required flags `--name` [Name of Deployment] and `--model_server_image` [Docker image to use]
    - optional flags `--memory` [amount of memory requested by each node], `--cpu` [number of cpus requested by each node], `--replicas` [number of nodes to spawn]

```bash
ks prototype use io.ksonnet.pkg.h2o3-static h2o3-static \
--name h2o3-static \
--namespace kubeflow \
--memory 1 \
--cpu 1 \
--replicas 2 \
--model_server_image <location_of_docker_image>

ks apply <my_environment_name> -c h2o3-static
```
- run `kubectl get svc -n kubeflow` to find the External IP address.
- Open a jupyter notebook on a local computer that has H2O installed locally.

```python
import h2o
h2o.init(port="<External IP address>", port=54321)
```
- You can now follow the steps for running H2O 3 AutoML that can be found [here](http://docs.h2o.ai/h2o/latest-stable/h2o-docs/automl.html)
