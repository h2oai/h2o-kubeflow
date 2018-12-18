# Base image for Driverless AI components in Kubeflow Pipelines
# includes: kubectl, ksonnet, jsonnet, python3.6
# Maintainer: Nicholas Png
# Contact: nicholas.png@h2o.ai

FROM ubuntu:16.04

# Install base requirements
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
      wget \
      curl \
      apt-utils \
      python-software-properties \
      default-jre \
      nginx \
      libzmq-dev \
      libblas-dev \
      apache2-utils \
      software-properties-common

# Get kubectl
RUN \
  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
  chmod +x ./kubectl && \
  mv ./kubectl /usr/local/bin/kubectl

# Get ksonnet
RUN \
  wget https://github.com/ksonnet/ksonnet/releases/download/v0.13.1/ks_0.13.1_linux_amd64.tar.gz && \
  tar -xzvf ks_0.13.1_linux_amd64.tar.gz && \
  chmod +x ./ks_0.13.1_linux_amd64/ks && \
  cp ks_0.13.1_linux_amd64/ks /usr/local/bin/ks && \
  rm ks_0.13.1_linux_amd64.tar.gz

# Install Driverless AI
RUN \
  wget https://s3.amazonaws.com/artifacts.h2o.ai/releases/ai/h2o/dai/rel-1.4.2-9/x86_64-centos7/dai-1.4.2-linux-x86_64.sh && \
  chmod +x ./dai-1.4.2-linux-x86_64.sh && \
  ./dai-1.4.2-linux-x86_64.sh && \
  rm dai-1.4.2-linux-x86_64.sh

RUN \
  echo "export PATH=/dai-1.4.2-linux-x86_64/python/bin:$PATH" >> /root/.bashrc && \
  echo "export LD_LIBRARY_PATH=/dai-1.4.2-linux-x86_64/python/lib" >> /root/.bashrc

ENV PATH=/dai-1.4.2-linux-x86_64/python/bin:$PATH
ENV LD_LIBRARY_PATH=/dai-1.4.2-linux-x86_64/python/lib

#Install gcloud sdk
RUN \
  export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
  echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get -y update && \
  apt-get install -y google-cloud-sdk
