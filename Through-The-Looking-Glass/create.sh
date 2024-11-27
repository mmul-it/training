#!/bin/bash

CTLP="ctlplane"
TEST="test"
PROD="prod"

cat <<EOF > kind-${CTLP}-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 6443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
EOF

cat <<EOF > kind-${TEST}-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 7443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
EOF

cat <<EOF > kind-${PROD}-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 8443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
EOF

kind create cluster --name ${CTLP} --config kind-${CTLP}-config.yml
kind create cluster --name ${TEST} --config kind-${TEST}-config.yml
kind create cluster --name ${PROD} --config kind-${PROD}-config.yml

export METALLB_VERSION='v0.14.8'
for K8S in ${CTLP} ${TEST} ${PROD}; do
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
  kubectl config use-context kind-${K8S}
  kubectl apply -f kind-${K8S}-metallb-pools.yml
done

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

for K8S in ${CTLP} ${TEST} ${PROD}; do
  kubectl config use-context kind-${K8S}
  helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
  kubectl -n monitoring expose service prometheus-kube-prometheus-prometheus --name=prometheus-kube-prometheus-prometheus-lb --type=LoadBalancer
  eval "PROMETHEUS_PROM_${K8S}=$(kubectl -n monitoring get svc prometheus-kube-prometheus-prometheus-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
  kubectl -n monitoring expose service prometheus-kube-prometheus-alertmanager --name=prometheus-kube-prometheus-alertmanager-lb --type=LoadBalancer
  eval "PROMETHEUS_ALERT_${K8S}=$(kubectl -n monitoring get svc prometheus-kube-prometheus-alertmanager-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
done

kubectl config use-context kind-${CTLP}
kubectl -n monitoring expose deployment prometheus-grafana --type=LoadBalancer --name=prometheus-grafana-lb
CTLP_GRAFANA_UI=$(kubectl -n monitoring get svc prometheus-grafana-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')

echo "Grafana web interface: ${CTLP_GRAFANA_UI}"
for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo -n "(${K8S}) Prometheus prometheus-kube-prometheus-prometheus-lb: "
  eval "echo \${PROMETHEUS_PROM_${K8S}}"
  echo -n "(${K8S}) Prometheus prometheus-kube-prometheus-alertmanager-lb: "
  eval "echo \${PROMETHEUS_ALERT_${K8S}}"
done
