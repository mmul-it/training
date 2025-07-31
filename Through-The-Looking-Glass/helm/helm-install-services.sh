#!/bin/bash

set -e

CTLP="ctlplane"
TEST="test"
PROD="prod"

PROMETHEUS_HELM_CHART='75.15.1'
TEMPO_HELM_CHART='1.46.1'
LOKI_HELM_CHART='6.33.0'
OTEL_HELM_CHART='0.129.0'
GRAFANA_HELM_CHART='9.3.0'

# Service IPs
eval "TEMPO_${CTLP}"='172.18.0.102'
eval "LOKI_${CTLP}"='172.18.0.103'
eval "OTEL_${CTLP}"='172.18.0.104'
eval "GRAFANA_${CTLP}"='172.18.0.105'
eval "PROMETHEUS_${CTLP}"='172.18.0.100'
eval "PROMETHEUS_FEDERATE_${CTLP}"='172.18.0.101'
eval "PROMETHEUS_FEDERATE_${TEST}"='172.18.0.120'
eval "PROMETHEUS_FEDERATE_${PROD}"='172.18.0.140'

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
  echo; echo "### Install Prometheus Federate on kind-${K8S} ###"; echo
  kubectl config use-context kind-${K8S}
  # Install
  helm upgrade --install prometheus-federate prometheus-community/kube-prometheus-stack \
    --version ${PROMETHEUS_HELM_CHART} \
    --namespace prometheus-federate \
    --create-namespace \
    --values ${WORKDIR}/helm-prometheus-federate-${K8S}.yml
  # Expose
  kubectl --namespace prometheus-federate delete service prometheus-federate-kube-p-prometheus-lb 2> /dev/null || true
  kubectl --namespace prometheus-federate expose service prometheus-federate-kube-p-prometheus \
    --name prometheus-federate-kube-p-prometheus-lb \
    --type LoadBalancer \
    --load-balancer-ip $(eval "echo \${PROMETHEUS_FEDERATE_${K8S}}")
done

echo; echo "### Install Prometheus main collector on kind-${CTLP} ###"; echo
# Move back to the CTLP context
kubectl config use-context kind-${CTLP}
# Install
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --version=${PROMETHEUS_HELM_CHART} \
  --namespace prometheus \
  --create-namespace \
  --values ${WORKDIR}/helm-prometheus-${CTLP}.yml
# Expose
kubectl --namespace prometheus delete service prometheus-kube-prometheus-prometheus-lb 2> /dev/null || true
kubectl --namespace prometheus expose service prometheus-kube-prometheus-prometheus \
  --name prometheus-kube-prometheus-prometheus-lb \
  --type LoadBalancer \
  --load-balancer-ip $(eval "echo \${PROMETHEUS_${CTLP}}")

#########
# Tempo #
#########

echo; echo "### Install Tempo on kind-${CTLP} ###"; echo
# Install
helm upgrade --install tempo grafana/tempo-distributed \
  --version ${TEMPO_HELM_CHART} \
  --namespace tempo \
  --create-namespace \
  --values ${WORKDIR}/helm-tempo-ctlplane.yml
# Expose
kubectl --namespace tempo delete service tempo-distributor-lb 2> /dev/null || true
kubectl --namespace tempo expose service tempo-distributor \
  --name tempo-distributor-lb \
  --type LoadBalancer \
  --load-balancer-ip $(eval "echo \${TEMPO_${CTLP}}")

########
# Loki #
########

echo; echo "### Install Loki on kind-${CTLP} ###"; echo
# Install
helm upgrade --install loki grafana/loki \
  --version ${LOKI_HELM_CHART} \
  --namespace loki \
  --create-namespace \
  -f ${WORKDIR}/helm-loki-ctlplane.yml
# Expose
kubectl --namespace loki delete service loki-gateway-lb 2> /dev/null || true
kubectl --namespace loki expose deployment loki-gateway \
  --name loki-gateway-lb \
  --type LoadBalancer \
  --load-balancer-ip $(eval "echo \${LOKI_${CTLP}}")

##################
# OTEL-Collector #
##################

echo; echo "### Install OTEL Collector on kind-${CTLP} ###"; echo
# Install
helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  --version ${OTEL_HELM_CHART} \
  --create-namespace \
  --namespace otel-collector \
  -f ${WORKDIR}/helm-otel-collector-ctlplane.yml
# Expose
kubectl --namespace otel-collector delete service otel-collector-lb 2> /dev/null || true
kubectl --namespace otel-collector expose service otel-collector-opentelemetry-collector \
  --name otel-collector-lb \
  --type LoadBalancer \
  --load-balancer-ip $(eval "echo \${OTEL_${CTLP}}")

###########
# Grafana #
###########

# Dashboards: https://github.com/dotdc/grafana-dashboards-kubernetes
echo; echo "### Install Grafana on kind-${CTLP} ###"; echo
# Install
helm upgrade --install grafana grafana/grafana \
  --version ${GRAFANA_HELM_CHART} \
  --namespace grafana \
  --create-namespace \
  -f ${WORKDIR}/helm-grafana-ctlplane.yml
# Expose
kubectl --namespace grafana delete service grafana-lb 2> /dev/null || true
kubectl --namespace grafana expose deployment grafana \
  --name grafana-lb \
  --port 80 \
  --target-port 3000 \
  --type LoadBalancer \
  --load-balancer-ip $(eval "echo \${GRAFANA_${CTLP}}")

########################
# Assign services vars #
########################

echo; echo "### Get Service IPs ###"; echo
for K8S in ${CTLP} ${TEST} ${PROD}; do
  kubectl config use-context kind-${K8S}
  eval "SVC_PROMETHEUS_FEDERATE_${K8S}=$(kubectl --namespace prometheus-federate get svc prometheus-federate-kube-p-prometheus-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
done
kubectl config use-context kind-${CTLP}
eval "SVC_PROMETHEUS_${CTLP}=$(kubectl --namespace prometheus get svc prometheus-kube-prometheus-prometheus-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "SVC_TEMPO_${CTLP}=$(kubectl --namespace tempo get svc tempo-distributor-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "SVC_LOKI_${CTLP}=$(kubectl --namespace loki get svc loki-gateway-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "SVC_OTEL_${CTLP}=$(kubectl --namespace otel-collector get svc otel-collector-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "SVC_GRAFANA_${CTLP}=$(kubectl --namespace grafana get svc grafana-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
eval "GRAFANA_PW_${CTLP}=$(kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo)"

#######################
# Print services vars #
#######################

kubectl get svc -A --field-selector 'spec.type=LoadBalancer' --sort-by '.status.loadBalancer.ingress[0].ip'

for K8S in ${CTLP} ${TEST} ${PROD}; do
  echo -n "(${K8S}) Prometheus: "
  eval "echo \${SVC_PROMETHEUS_FEDERATE_${K8S}}"
done
echo -n "(${CTLP}) Prometheus collector: "
eval "echo \${SVC_PROMETHEUS_${CTLP}}"
echo -n "(${CTLP}) Tempo frontend: "
eval "echo \${SVC_TEMPO_${CTLP}}"
echo -n "(${CTLP}) Loki: "
eval "echo \${SVC_LOKI_${CTLP}}"
echo -n "(${CTLP}) OTEL Collector: "
eval "echo \${SVC_OTEL_${CTLP}}"
echo -n "(${CTLP}) Grafana UI: "
eval "echo http://\${SVC_GRAFANA_${CTLP}}"
echo -n "(${CTLP}) Grafana PW: "
eval "echo \${GRAFANA_PW_${CTLP}}"
