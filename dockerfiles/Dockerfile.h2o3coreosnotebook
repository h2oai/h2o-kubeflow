# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/tensorflow-notebook:latest

LABEL maintainer='Florian JUDITH <florian.judith.b@gmail.com'

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-transport-https \
    curl \
    g++ \
    jed \
    libav-tools \
    libcupti-dev \
    lsb-release \
    openssh-client \
    pkg-config \
    python \
    python-dev \
    unzip \
    vim \
    zip \
    zlib1g-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install ksonnet
RUN wget --quiet https://github.com/ksonnet/ksonnet/releases/download/v0.9.2/ks_0.9.2_linux_amd64.tar.gz && \
    tar -zvxf ks_0.9.2_linux_amd64.tar.gz && \
    mv ks_0.9.2_linux_amd64/ks /usr/local/bin/ks && \
    rm -rf ks_0.9.2_linux_amd64* && \
    chmod +x /usr/local/bin/ks

# Install CUDA Profile Tools and other python packages
RUN pip --no-cache-dir install \
    Pillow \
    h5py \
    ipykernel \
    matplotlib \
    numpy \
    scipy \
    sklearn \
    kubernetes \
    grpcio \
    ktext \
    annoy \
    nltk \
    pydot \
    pydot-ng \
    graphviz \
    && \
    python -m ipykernel.kernelspec

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
    'nomkl' \
    'ipywidgets=6.0*' \
    'pandas=0.22*' \
    'numexpr=2.6*' \
    'matplotlib=2.0*' \
    'scipy=0.19*' \
    'seaborn=0.7*' \
    'scikit-learn=0.18*' \
    'scikit-image=0.12*' \
    'sympy=1.0*' \
    'cython=0.25*' \
    'patsy=0.4*' \
    'statsmodels=0.8*' \
    'cloudpickle=0.2*' \
    'dill=0.2*' \
    'numba=0.31*' \
    'bokeh=0.12*' \
    'sqlalchemy=1.1*' \
    'hdf5=1.8.17' \
    'h5py=2.6*' \
    'vincent=0.4.*' \
    'beautifulsoup4=4.5.*' \
    'xlrd'  && \
    conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy

# Install graphviz package
RUN apt-get update && apt-get install -yq --no-install-recommends graphviz \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Oracle Java 8
RUN \
  apt-get update && apt-get install -y wget unzip python-pip python-sklearn python-pandas python-numpy python-matplotlib software-properties-common python-software-properties && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update -q && \
  echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install H2O.3
RUN pip --no-cache-dir install \
        requests \
        tabulate \
        scikit-learn \
        colorama \
        future
RUN pip --no-cache-dir --trusted-host h2o-release.s3.amazonaws.com install -f \
        http://h2o-release.s3.amazonaws.com/h2o/latest_stable_Py.html h2o

ENV CLOUD_SDK_VERSION 168.0.0
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk=${CLOUD_SDK_VERSION}-0 kubectl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

# Activate ipywidgets extension in the environment that runs the notebook server
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix

RUN curl -L -o bazel.sh https://github.com/bazelbuild/bazel/releases/download/0.8.0/bazel-0.8.0-installer-linux-x86_64.sh && chmod a+x ./bazel.sh && ./bazel.sh && rm ./bazel.sh
SHELL ["/bin/bash", "-c"]

RUN git clone https://github.com/tensorflow/models.git /home/$NB_USER/tensorflow-models && git clone https://github.com/tensorflow/benchmarks.git /home/$NB_USER/tensorflow-benchmarks
# Import matplotlib the first time to build the font cache.
ENV XDG_CACHE_HOME /home/$NB_USER/.cache/
RUN pip install jupyter-tensorboard

# Create a conda environment for Python 2. We want to include as many of the
# packages from our root environment as we reasonably can, so we explicitly
# list that environment, then include everything unless it is Conda (which
# can only be in the root environment), Jupyterhub (which requires Python 3),
# or Python itself. We also want to include the pip packages, but we cannot
# install those via conda, so we list them, drop any conda packages, and
# then install them via pip. We do this on a best-effort basis, so if any
# packages from the Python 3 environment cannot be installed with Python 2,
# then we just skip them.
RUN conda_packages=$(conda list -e | cut -d '=' -f 1 | grep -v '#' | sort) && \
    pip_packages=$(pip --no-cache-dir list --format=freeze | cut -d '=' -f 1 | grep -v '#' | sort) && \
    pip_only_packages=$(comm -23 <(echo "${pip_packages}") <(echo "${conda_packages}")) && \
    conda create -n ipykernel_py2 python=2 --file <(echo "${conda_packages}" | grep -v conda | grep -v python | grep -v jupyterhub) && \
    source activate ipykernel_py2 && \
    python -m ipykernel install --user && \
    echo "${pip_only_packages}" | xargs -n 1 -I "{}" /bin/bash -c 'pip install --no-cache-dir {} || true' && \
    pip install --no-cache-dir tensorflow-transform && \
    source deactivate

RUN chown -R $NB_USER:users /etc/jupyter/ && \
    chown -R $NB_USER /home/$NB_USER/ && \
    chmod a+rx /usr/local/bin/* && \
    fix-permissions /etc/jupyter/ && \
    fix-permissions /home/$NB_USER/

USER $NB_UID