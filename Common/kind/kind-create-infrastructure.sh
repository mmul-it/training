#!/bin/bash

set -e

CTLP="ctlplane"
TEST="test"
PROD="prod"

# Because of the high number of processes that will be executed, some Linux
# system tweaks are suggested:
if grep -q "^fs.inotify.max_user_watches=" /etc/sysctl.conf; then
  sudo sed -i 's/^fs.inotify.max_user_watches=.*/fs.inotify.max_user_watches=655360/' /etc/sysctl.conf
else
  echo "fs.inotify.max_user_watches=655360" | sudo tee -a /etc/sysctl.conf
fi

if grep -q "^fs.inotify.max_user_instances=" /etc/sysctl.conf; then
  sudo sed -i 's/^fs.inotify.max_user_instances=.*/fs.inotify.max_user_instances=1280/' /etc/sysctl.conf
else
  echo "fs.inotify.max_user_instances=1280" | sudo tee -a /etc/sysctl.conf
fi

# Reload sysctl to apply changes
sudo sysctl -p

# Create the kind config files
cat <<EOF > kind-${CTLP}-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 6443
nodes:
- role: control-plane
  image: kindest/node:v1.31.0
EOF

cat <<EOF > kind-${TEST}-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 7443
nodes:
- role: control-plane
  image: kindest/node:v1.31.0
EOF

cat <<EOF > kind-${PROD}-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 8443
nodes:
- role: control-plane
  image: kindest/node:v1.31.0
EOF

for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo; echo "### Install kind cluster kind-${K8S} ###"; echo
  kind create cluster --name ${K8S} --config kind-${K8S}-config.yml
done

export METALLB_VERSION='v0.14.8'
for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo; echo "### Install MetalLB for kind-${K8S} ###"; echo
  kubectl config use-context kind-${K8S}
  kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
  kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
done

cat <<EOF > kind-${CTLP}-metallb-pools.yml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mypool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.0.100-172.18.0.110
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mypool
  namespace: metallb-system
spec:
  ipAddressPools:
  - mypool
EOF

cat <<EOF > kind-${TEST}-metallb-pools.yml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mypool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.0.120-172.18.0.130
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mypool
  namespace: metallb-system
spec:
  ipAddressPools:
  - mypool
EOF

cat <<EOF > kind-${PROD}-metallb-pools.yml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mypool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.0.140-172.18.0.150
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mypool
  namespace: metallb-system
spec:
  ipAddressPools:
  - mypool
EOF

for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo; echo "### Configure MetalLB pools for kind-${K8S} ###"; echo
  kubectl config use-context kind-${K8S}
  kubectl apply -f kind-${K8S}-metallb-pools.yml
done
