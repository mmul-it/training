#!/bin/bash

set -e

CTLP="ctlplane"
TEST="test"
PROD="prod"

WORKDIR=$(dirname "$0")

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

# In certain systems using the local DNS could lead to unexpected Kind/K8s
# behaviors, like resolving every service address with the 127.0.0.2 IP.
# Overriding docker dns configuration is a solution
DOCKER_CONF='/etc/docker/daemon.json'
DOCKER_DNS='8.8.8.8'
if ! jq -e ".dns == [\"${DOCKER_DNS}\"]" "${DOCKER_CONF}" > /dev/null; then
  # Add dns to Docker daemon
  sudo jq ". + {dns: [\"${DOCKER_DNS}\"]}" "${DOCKER_CONF}" | sudo tee -a "${DOCKER_CONF}"

  # Restart Docker daemon
  sudo systemctl restart docker
fi

# Install clusters
for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo; echo "### Install kind cluster kind-${K8S} ###"; echo
  kind create cluster --name ${K8S} --config ${WORKDIR}/kind-${K8S}-config.yml
done

# Install MetalLB
export METALLB_VERSION='v0.14.8'
for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo; echo "### Install MetalLB for kind-${K8S} ###"; echo
  kubectl config use-context kind-${K8S}
  kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
  kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
done

# Configure MetalLB
for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo; echo "### Configure MetalLB pools for kind-${K8S} ###"; echo
  kubectl config use-context kind-${K8S}
  kubectl apply -f ${WORKDIR}/kind-${K8S}-metallb-pools.yml
done
