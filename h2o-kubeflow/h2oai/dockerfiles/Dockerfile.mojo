# Base image for Driverless AI Mojos in Kubeflow Pipelines
# includes: java openjdk 8,
# Maintainer: Nicholas Png
# Contact: nicholas.png@h2o.ai

FROM ubuntu:16.04

ENV DAI_PYTHON_VERSION=master-42

RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
      vim \
      wget \
      curl \
      unzip \
      apt-utils \
      default-jre \
      nginx \
      net-tools \
      ca-certificates \
      build-essential \
      software-properties-common

# Install Oracle Java 8
RUN \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update -q && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y oracle-java8-installer && \
    apt-get clean

RUN \
  add-apt-repository ppa:deadsnakes/ppa && \
  apt-get -y update && \
  apt-get -y install \
    python3.6 \
    python3-setuptools \
    python3-pip

RUN curl https://bootstrap.pypa.io/get-pip.py | python3.6

RUN \
  pip3.6 install --force-reinstall pip==9.0.3 && \
  pip3.6 install flask requests tornado

RUN ln -fs /usr/bin/python3.6 /usr/bin/python
RUN ls -fs /usr/local/bin/pip3.6 /usr/local/bin/pip

COPY DAIMojoRestServer4-1.11.1.jar /opt/h2oai/dai/DAIMojoRestServer4-1.11.1.jar
COPY mojo-startup.sh /mojo-startup.sh
COPY mojo_tornado.py /mojo_tornado.py
RUN chmod +x /mojo-startup.sh

ENTRYPOINT ["/mojo-startup.sh", "/opt/h2oai/dai/license.sig", "/opt/h2oai/dai"]

EXPOSE 5555
