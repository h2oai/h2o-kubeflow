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

# install tools for kubeflow (ksonnet and jsonnet)
wget https://github.com/ksonnet/ksonnet/releases/download/v0.9.2/ks_0.9.2_linux_amd64.tar.gz
tar -xzvf ks_0.9.2_linux_amd64.tar.gz
cp ks_0.9.2_linux_amd64/ks /usr/bin/ks
chmod +x /usr/bin/ks

# NOTE: contained code may not be needed...
# --------------------------------------------
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
# test -d ~/.linuxbrew && PATH="$HOME/.linuxbrew/bin:$HOME/.linuxbrew/sbin:$PATH"
# test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
# test -r ~/.bash_profile && echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.bash_profile
# echo "export PATH='$(brew --prefix)/bin:$(brew --prefix)/sbin'":'"$PATH"' >>~/.profile
#
# source ~/.profile
# brew install jsonnet
# --------------------------------------------

# setup kubernetes cluster, spawn kubernetes master node
# needed to prevent issues later
swapoff -av
# spawn master node for k8s and dump logs to kube-init.txt for use later
kubeadm init > /opt/kubeflow/kube-init.txt
cat /opt/kubeflow/kube-init.txt | grep "kubeadm join" | awk '{$1=$1};1' >> /opt/kubeflow/k8s_slave_setup.sh

mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chmod 644 /home/ubuntu/.kube/config

# setup pod network using weave-net
sysctl net.bridge.bridge-nf-call-iptables=1
export kubever=$(sudo kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever&env.IPALLOC_RANGE=10.96.0.0/16"

# give kubectl read permission to pods
kubectl create clusterrolebinding read-binding --clusterrole=view --user=system:serviceaccount:default:default

touch /opt/kubeflow/config.txt
echo "ALLOW_BURST_TO_CLOUD="TRUE"" >> /opt/kubeflow/config.txt
echo "CLOUD_INSTANCES=0" >> /opt/kubeflow/config.txt
echo "REQUEST_NEW_NODE="FALSE"" >> /opt/kubeflow/config.txt
echo "KSONNET_APP=" >> /opt/kubeflow/config.txt
