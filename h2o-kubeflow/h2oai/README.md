# H2O.ai Deployments

## Ksonnet App Setup:
**NOTE:** The deployment steps assume that you have already set up a Kubernetes cluster and that `kubectl` and `ksonnet` have been installed/setup properly within your environment.

1. Create a new ksonnet app in your local environment
  * Run Command: `ks init <name_of_new_app>` and `cd <name_of_new_app>`

2. Grab Ksonnet registry and install necessary packages
    ```
    # add ksonnet registry to app containing all the kubeflow manifests as maintained by Google Kubeflow team
    ks registry add kubeflow https://github.com/kubeflow/kubeflow/tree/master/kubeflow
    # add ksonnet registry to app containing all the h2o component manifests
    ks registry add h2o-kubeflow <this_github_repo/h2o-kubeflow>
    ks pkg install kubeflow/core
    ks pkg install kubeflow/tf-serving
    ks pkg install kubeflow/tf-job
    ks pkg install h2o-kubeflow/h2oai
    ks env add <my environment name>
    ```
    You should be able to see the prototypes for `h2oai-driverlessai` and `h2oai-h2o3` after running `ks prototype list`:
    ```
    Nicholass-MBP:h2o-kubeflow-dev npng$ ks prototype list
    NAME                                  DESCRIPTION
    ====                                  ===========
    io.ksonnet.pkg.configMap              A simple config map with optional user-specified data
    io.ksonnet.pkg.deployed-service       A deployment exposed with a service
    io.ksonnet.pkg.h2oai-driverlessai     Driverless AI
    io.ksonnet.pkg.h2oai-h2o3             H2O3 Static Cluster
    io.ksonnet.pkg.namespace              Namespace with labels automatically populated from the name
    io.ksonnet.pkg.single-port-deployment Replicates a container n times, exposes a single port
    io.ksonnet.pkg.single-port-service    Service that exposes a single port
    ```

## H2O-3 Cluster (OSS)
H2O is an open source, in-memory, distributed, fast, and scalable machine learning and predictive analytics platform that allows you to build machine learning models on big data and provides easy productionalization of those models in an enterprise environment.

### H2O-3 Deployment Steps
**NOTE:** These deployment steps assume that you have already previously set up a Ksonnet application as defined above, and downloaded the necessary Ksonnet registries and packages.

1. Create a Docker image for Kubeflow to ingest. Files are located under `dockerfiles` data_directory
  * Run Command: `docker build -t <personal_repository>/h2o3-kubeflow:latest -f Dockerfile.h2o3` from the `dockerfiles` directory

2. Push the new docker image to a remote repository that Kubeflow can access later `docker push <personal_repository>/h2o3-kubeflow:latest`

3. Deploy the H2O-3 Cluster to your Kubernetes cluster
    ```
    ks prototype use io.ksonnet.pkg.h2oai-h2o3 <component name> \
    --name <deployment name> \
    --namespace kubeflow \
    --memory 1 \
    --cpu 1 \
    --replicas 2 \
    --model_server_image <location_of_docker_image>

    ks apply <my environment name> -c <component name>
    ```
    **NOTE**: component names are used by Kubeflow to deploy to Kubernetes while deployment names are what Kubernetes will show as the name of the process running in Kubernetes

    Running `kubectl get deployments` will show:
    ```
    Nicholass-MBP:h2o-kubeflow-dev npng$ kubectl get deployments
    NAME                      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
    <deployment name>         3         3         3            3           13m
    ```
    Where the name in the `NAME` column is the specified `<deployment name>`

4. You will be able to see the exposed ip address and port for the cluster using: `kubectl get svc`, and you will be able to connect to the cluster at `external ip + port 54321`

## Driverless AI (Enterprise)

H2O Driverless AI is an artificial intelligence (AI) platform for automatic machine learning. Driverless AI automates some of the most difficult data science and machine learning workflows such as feature engineering, model validation, model tuning, model selection and model deployment. It aims to achieve highest predictive accuracy, comparable to expert data scientists, but in much shorter time thanks to end-to-end automation. Driverless AI also offers automatic visualizations and machine learning interpretability (MLI).

### Driverless AI Deployment Steps
**NOTE:** These deployment steps assume that you have already previously set up a Ksonnet application as defined above, and downloaded the necessary Ksonnet registries and packages.

1. make sure to obtain a copy of the Driverless AI docker image. Download links can be obtained from this link [https://www.h2o.ai/download/](https://www.h2o.ai/download/). There are multiple images for varying platforms and architectures, so make sure to download the correct one.

2. Load the docker image to you Kubernetes cluster: `docker load < downloaded_driverless_ai_image.tar.gz`. Since this image is not public, you may need to load it to each node in the cluster, or to an internal repository.

3. **(OPTIONAL)** Create a Kubernetes ConfigMap to configure your Driverless AI deployment. The expectation is that there are minimally 2 files in the ConfigMap: `license.sig` containing the license key for Driverless AI and `config.toml` which is a file that can issue configuration overrides for Driverless AI. More information regarding the `config.toml` can be found [here](http://docs.h2o.ai/driverless-ai/latest-stable/docs/userguide/config_toml.html).

  **NOTE:** all files inside the directory path will be loaded for consumption.
  **Example:** User includes a config.toml that overrides authentication with local authentication (htpasswd), htpasswd file is contained in `/path/to/configuration/files` as `/path/to/configuration/files/htpasswd`, then Driverless AI will be able to see the file at path `/config/htpasswd`

  ```
  kubectl create configmap driverless --from-file="/path/to/configuration/files/"
  ```

4. Deploy Driverless AI to your Kubernetes Cluster
  ```
  ks prototype use io.ksonnet.pkg.h2oai-driverlessai <component name> \
  --name <deployment name>
  --namespace kubeflow \
  --memory 16 \
  --cpu 4 \
  --gpu 0 \
  --pvcSize 50 \
  --configMapName <configmap name> \
  --model_server_image <name of Driverless AI image in docker>
  ```
  **NOTE**: component names are used by Kubeflow to deploy to Kubernetes while deployment names are what Kubernetes will show as the name of the process running in Kubernetes

  Running `kubectl get deployments` will show:
  ```
  Nicholass-MBP:h2o-kubeflow-dev npng$ kubectl get deployments
  NAME                DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
  <deployment name>   1         1         1            1           17m
  ```
5. You will be able to see the exposed ip address and port for the cluster using: `kubectl get svc`. And you can connect to Driverless AI using the `external ip address + port 12345`

6. If you did not provide a ConfigMap, Driverless AI will request a license key after logging in.


## Mojo Rest Server Deployment Steps
**NOTE:** These deployment steps assume that you already have a mojo artifact generated by Driverless AI and and that you have a valid license for Driverless AI. Additionally, these deployment steps assume that you have already previously set up a Ksonnet application as defined above, and downloaded the necessary Ksonnet registries and packages.

1. Make sure to build the docker image using `h2o-kubeflow/h2o-kubeflow/h2oai/dockerfiles/Dockerfile.mojo` and then push it to an accessible repository. `docker push <docker image>:<tag>`

2. **(OPTIONAL)** Create a Kubernetes ConfigMap to configure your Driverless AI deployment. The expectation is that there is minimally 1 file in the ConfigMap: `license.sig` containing the license key for Driverless AI.

  ```
  kubectl create configmap mojo-configs --from-file="/path/to/mojo/config/files/"
  ```

3. Deploy the mojo rest server to your Kubernetes Cluster
  ```
  ks prototype use io.ksonnet.pkg.h2oai-mojo-rest-server <component name> \
  --name <deployment name> \
  --namespace kubeflow \
  --memory 4 \
  --cpu 1 \
  --configMapName <optional config map name> \
  --pvcSize <optional size for pvc if does not already exist>
  --pvcName <optional name for pvc that already exists, overrides pvcSize> \
  --licenseLocation <filepath to license in container, will be /config/license.sig if included configMapName> \
  --mojoLocation <filepath to directory where mojos will live, will be /tmp/mojo-models/ if included pvcName> \
  --model_server_image <docker image>:<tag>
  ```

4. You will be able to see the exposed ip address and port for the cluster using: `kubectl get svc`. And you can connect to Driverless AI using the `external ip address + port 5555`

5. If you did not provide a ConfigMap, the mojo-rest-server pod will wait until one is copied in/mounted. If you did not provide a pvcName, the mojo-rest-server will not be able to do anything until a mojo artifact is added into the specified mojoLocation path in the pod.

6. You can access the rest calls using the following protocols:
  * `http://<ip address>:5555/modelfeatures?name=<name of mojo file artifact ex. pipeline.mojo>`
  * `http://<ip address>:5555/scorerow?name=<name of mojo file artifact ex. pipeline.mojo>&row=<comma separated string>`
  * **POST REQUEST:** with `{file: /path/to/file.csv, name: name_of_mojo_to_score_with, header: bool_whether_file_has_header}`
