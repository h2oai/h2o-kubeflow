#!/bin/bash

# install kubectl, kubeadm, kubernetes-cni
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

cat <<EOF > kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
mv kubernetes.list /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y build-essential curl file git
apt-get install -y docker.io
apt-get install -y kubelet kubeadm kubectl kubernetes-cni
