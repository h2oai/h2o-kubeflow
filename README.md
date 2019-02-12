# H2O + Kubeflow Integration

This is a project for the integration of H2O.ai and Kubeflow. The integration of H2O and Kubeflow is an extremely powerful opportunity, as it provides a turn-key solution for easily deployable and highly scalable machine learning applications, with minimal input required from the user.

#### Kubeflow
[Kubeflow](https://github.com/kubeflow/kubeflow) is an open source project managed by Google and built on top of their Kubernetes engine. It is designed to alleviate some of the more tedious tasks associated with machine learning. Kubeflow helps orchestrate deployment of apps through the full cycle of development, testing, and production, and allows for resource scaling as demand increases.

#### H2O 3
[H2O 3’s](http://docs.h2o.ai/h2o/latest-stable/h2o-docs/index.html) goal is to reduce the time spent by data scientists on time-consuming tasks like designing grid search algorithms and tuning hyperparameters, while also providing an interface that allows newer practitioners an easy foothold into the machine learning space.

#### Driverless AI
[Driverless AI](http://docs.h2o.ai/driverless-ai/latest-stable/docs/userguide/index.html) is an artificial intelligence (AI) platform for automatic machine learning. Driverless AI automates some of the most difficult data science and machine learning workflows such as feature engineering, model validation, model tuning, model selection and model deployment. It aims to achieve highest predictive accuracy, comparable to expert data scientists, but in much shorter time thanks to end-to-end automation. Driverless AI also offers automatic visualizations and machine learning interpretability (MLI).

#### Contents
This repository contains all the necessary components for deploying H2O.ai's core products on Kubeflow

```
h2o-kubeflow
|-- dockerfiles
    |-- A copy of dockerfiles that will are currently part of components in POC
|-- h2o-kubeflow // --> Ksonnet registry containing all packages offered in this repo
    |-- h2oai
        |-- Ksonnet package containing deployment templates for core offerings from H2O.ai [H2O-3, Driverless AI]
    |-- <all other package directories>
        |-- Ksonnet packages built as a proof of concept. Not consistently maintained
    |-- registry.yaml // --> file defining all packages included in the registry
```

#### Quick Start
Complete deployment steps can be found inside this directory: [https://github.com/h2oai/h2o-kubeflow/tree/master/h2o-kubeflow/h2oai](https://github.com/h2oai/h2o-kubeflow/tree/master/h2o-kubeflow/h2oai).

Repository for Kubeflow can be found [here](https://github.com/kubeflow/kubeflow), and complete steps to deploy Kubeflow can be found in their [User Documentation](https://www.kubeflow.org/docs/started/getting-started/)

You will also need [ksonnet](https://ksonnet.io) and [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) command line tools.

- Create a Kubernetes cluster. Either on-prem or on Google Cloud
- Run the following commands to setup your ksonnet app (how you deploy Kubeflow)

**NOTE:** Kubeflow is managed by Google's Kubeflow team, and some of the commands to deploy Kubeflow's core components may change. Refer to https://www.kubeflow.org/docs/started/getting-started/ for comprehensive steps to launch Kubeflow. The H2O Components are not dependent on Kubeflow running to be able to be deployed, but will benefit from Kubeflow's core functionality. It is recommended that you launch Kubeflow prior to starting the H2O deployments, but is not required.

```bash
# create ksonnet app
ks init <my_ksonnet_app>
cd <my_ksonnet_app>

# add ksonnet registry to app containing all the kubeflow manifests as maintained by Google Kubeflow team
ks registry add kubeflow https://github.com/kubeflow/kubeflow/tree/master/kubeflow
# add ksonnet registry to app containing all the h2o component manifests
ks pkg install h2o-kubeflow/h2oai

# create namespace and environment for deployments
kubectl create namespace kubeflow
ks env add <my_environment_name>
```

- Deploy H2O 3 by running the following commands. You will first need to build a docker image of H2O-3 that can be consumed by Kubernetes. See this directory: [https://github.com/h2oai/h2o-kubeflow/tree/master/h2o-kubeflow/h2oai/dockerfiles](https://github.com/h2oai/h2o-kubeflow/tree/master/h2o-kubeflow/h2oai/dockerfiles) for necessary dockerfile and scripts. Be sure to push it to a repository that Kubernetes has pull access to.

```bash
ks prototype use io.ksonnet.pkg.h2oai-h2o3 h2o3 \
--name h2o3 \
--namespace kubeflow \
--memory 2 \
--cpu 1 \
--replicas 2 \
--model_server_image <location_of_docker_image>

ks apply <my_environment_name> -c h2o3
```
- run `kubectl get svc -n kubeflow` to find the External IP address.
- Open a jupyter notebook on a local computer that has H2O installed locally.

```python
import h2o
h2o.init(port="<External IP address>", port=54321)
```
- You can now follow the steps for running H2O 3 AutoML that can be found [here](http://docs.h2o.ai/h2o/latest-stable/h2o-docs/automl.html)

#### Burst to Cloud (NOT CONSISTENTLY MAINTAINED)

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
