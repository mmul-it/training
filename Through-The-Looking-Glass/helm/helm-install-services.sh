#!/bin/bash

set -e

CTLP="ctlplane"
TEST="test"
PROD="prod"

WORKDIR=$(dirname "$0")

##############
# Helm repos #
##############

echo; echo "### Add helm repositories ###"; echo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

##############
# Prometheus #
##############

# For FEDERATION check
# https://stackoverflow.com/questions/64918491/prometheus-for-k8s-multi-clusters
# https://prometheus.io/docs/prometheus/latest/federation/#configuring-federation
for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo; echo "### Install Prometheus on kind-${K8S} ###"; echo
  kubectl config use-context kind-${K8S}
  # Install
  helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --values ${WORKDIR}/helm-prometheus-${K8S}.yml
  # Expose
  kubectl -n monitoring expose service prometheus-kube-prometheus-prometheus \
    --name=prometheus-kube-prometheus-prometheus-lb \
    --type=LoadBalancer
done

# To fix metrics expositions
# Check https://artifacthub.io/packages/helm/kube-prometheus-stack-oci/kube-prometheus-stack/14.2.0#kubeproxy
# for K8S in ${CTLP} ${TEST} ${PROD}; do
#   kubectl -n kube-system get cm kube-proxy -o yaml | \
#     sed 's/metricsBindAddress:.*$/metricsBindAddress: 0.0.0.0:10249/' | 	
#     kubectl apply -f -
#  Force pod recreation
#  kubectl -n kube-system delete pod -l k8s-app=kube-proxy
# done

#########
# Tempo #
#########

echo; echo "### Install Tempo on kind-${CTLP} ###"; echo
# Install
helm install tempo grafana/tempo-distributed \
  --namespace tempo \
  --create-namespace \
  --values ${WORKDIR}/helm-tempo-ctlplane.yml
# Expose
kubectl -n tempo expose service tempo-distributor \
  --name=tempo-distributor-lb \
  --type=LoadBalancer

########
# Loki #
########

echo; echo "### Install Loki on kind-${CTLP} ###"; echo
# Install
helm install loki grafana/loki \
  --namespace loki \
  --create-namespace \
  -f ${WORKDIR}/helm-loki-ctlplane.yml
# Expose
kubectl -n loki expose deployment loki-gateway \
  --name=loki-gateway-lb \
  --type=LoadBalancer

##################
# OTEL-Collector #
##################

echo; echo "### Install OTEL Collector on kind-${CTLP} ###"; echo
# Install
helm install otel-collector open-telemetry/opentelemetry-collector \
        --create-namespace \
        --namespace otel-collector \
        -f ${WORKDIR}/helm-opentelemetry-collector.yml
# Expose
kubectl -n otel-collector expose service otel-collector-opentelemetry-collector \
  --name otel-collector-lb \
  --type LoadBalancer \

########################
# Assign services vars #
########################

echo; echo "### Get variables ###"; echo
for K8S in ${TEST} ${PROD}; do
  kubectl config use-context kind-${K8S}
  eval "PROMETHEUS_${K8S}=$(kubectl -n monitoring get svc prometheus-kube-prometheus-prometheus-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
done
kubectl config use-context kind-${CTLP}
eval "PROMETHEUS_${CTLP}=$(kubectl -n monitoring get svc prometheus-kube-prometheus-prometheus-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "TEMPO_DISTRIB_${CTLP}=$(kubectl -n tempo get svc tempo-distributor-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "LOKI_${CTLP}=$(kubectl -n loki get svc loki-gateway-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "OTEL_COLLECTOR_${CTLP}=$(kubectl -n otel-collector get svc otel-collector-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"

###########
# Grafana #
###########

# Dashboards: https://github.com/dotdc/grafana-dashboards-kubernetes

echo; echo "### Install Grafana on kind-${CTLP} ###"; echo
# Install
helm install grafana grafana/grafana \
  --namespace grafana \
  --create-namespace \
  -f ${WORKDIR}/helm-grafana-ctlplane.yml
# Expose
kubectl -n grafana patch svc grafana \
  -p '{"spec": {"type": "LoadBalancer"}}'
# Assign
eval "GRAFANA_UI_${CTLP}=$(kubectl -n grafana get svc grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "GRAFANA_PW_${CTLP}=$(kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)"

#######################
# Print services vars #
#######################

kubectl get svc -A --field-selector spec.type=LoadBalancer --sort-by='.status.loadBalancer.ingress[0].ip'

for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo -n "(${K8S}) Prometheus: "
  eval "echo \${PROMETHEUS_${K8S}}"
done
echo -n "(${CTLP}) Tempo frontend: "
eval "echo \${TEMPO_DISTRIB_${CTLP}}"
echo -n "(${CTLP}) Loki: "
eval "echo \${LOKI_${CTLP}}"
echo -n "(${CTLP}) OTEL Collector: "
eval "echo \${OTEL_COLLECTOR_${CTLP}}"
echo -n "(${CTLP}) Grafana UI: "
eval "echo http://\${GRAFANA_UI_${CTLP}}"
echo -n "(${CTLP}) Grafana PW: "
eval "echo \${GRAFANA_PW_${CTLP}}"
