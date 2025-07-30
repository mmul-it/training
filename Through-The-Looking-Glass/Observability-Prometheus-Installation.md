# Lab | Create a Federated Prometheus Infrastructure

This lab will create a Prometheus infrastructure inside the three Kubernetes
Kind clusters created in [Kubernetes-Install-3-Kind-Clusters.md](../../Common/Kubernetes-Install-3-Kind-Clusters.md)
with one collector and three federated instances.

## Preparation

The Helm chart used to intall Prometheus are available at [https://prometheus-community.github.io/helm-charts]()
and can be configured locally as follows:

```console
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
```

For each instance a pre filled Helm values file should be locally downloaded
from this repository:

- [helm/helm-prometheus-ctlplane.yml](helm/helm-prometheus-ctlplane.yml)
- [helm/helm-prometheus-federate-ctlplane.yml](helm/helm-prometheus-federate-ctlplane.yml)
- [helm/helm-prometheus-federate-test.yml](helm/helm-prometheus-federate-test.yml)
- [helm/helm-prometheus-federate-prod.yml](helm/helm-prometheus-federate-prod.yml)

## Prometheus federate installation

Each Kubernetes cluster will have one federated Prometheus instance, activated
and exposed with a dedicated IP address.

The Helm chart values contains something common to all the instances:

```yaml
grafana:
  enabled: false

alertmanager:
  enabled: false

prometheus:
  prometheusSpec:
    externalLabels:
      cluster: "ctlplane"
```

This configuration will add a `cluster` label to all the metrics identifying the
source cluster, and will help a lot making queries.

The IP addresses for the exposed service will be:

- federate-ctlplane: **172.18.0.101**
- federate-test: **172.18.0.120**
- federate-prod: **172.18.0.140**

This command sequence will install the Helm chart on each cluster:

```console
$ export PROMETHEUS_HELM_CHART='75.15.1'
(no output)

$ for K8S in ctlplane test prod; do
  echo; echo "### Install Prometheus Federate on kind-${K8S} ###"; echo
  kubectl config use-context kind-${K8S}
  # Install
  helm upgrade --install prometheus-federate prometheus-community/kube-prometheus-stack \
    --version ${PROMETHEUS_HELM_CHART} \
    --namespace prometheus-federate \
    --create-namespace \
    --values helm-prometheus-federate-${K8S}.yml
done

### Install Prometheus Federate on kind-ctlplane ###

Switched to context "kind-ctlplane".
Release "prometheus-federate" does not exist. Installing it now.
NAME: prometheus-federate
...
STATUS: deployed
...

### Install Prometheus Federate on kind-test ###

Switched to context "kind-test".
Release "prometheus-federate" does not exist. Installing it now.
NAME: prometheus-federate
...
STATUS: deployed
...

### Install Prometheus Federate on kind-prod ###

Switched to context "kind-prod".
Release "prometheus-federate" does not exist. Installing it now.
NAME: prometheus-federate
...
STATUS: deployed
...
```

Exposing the different services with the defined IPs will be done by using the
`kubectl expose` command:

```console
$ kubectl --context kind-ctlplane --namespace prometheus-federate \
    expose service prometheus-federate-kube-p-prometheus \
    --name prometheus-federate-kube-p-prometheus-lb \
    --type LoadBalancer \
    --load-balancer-ip 172.18.0.101
service/prometheus-federate-kube-p-prometheus-lb exposed

$ kubectl --context kind-test --namespace prometheus-federate \
    expose service prometheus-federate-kube-p-prometheus \
    --name prometheus-federate-kube-p-prometheus-lb \
    --type LoadBalancer \
    --load-balancer-ip 172.18.0.120
service/prometheus-federate-kube-p-prometheus-lb exposed

$ kubectl --context kind-prod --namespace prometheus-federate \
    expose service prometheus-federate-kube-p-prometheus \
    --name prometheus-federate-kube-p-prometheus-lb \
    --type LoadBalancer \
    --load-balancer-ip 172.18.0.140
service/prometheus-federate-kube-p-prometheus-lb exposed
```

## Prometheus collector installation

Now that each cluster have a Prometheus federated instance it is time to install
the collector instance that will put everything together.

The Helm values file contains specific exclusions for the monitored services,
since we just want this instance to collect the other federated Prometheus, and
it also omits to configure other components that the previously installed
federated instance already did:

```yaml
# Disable all monitoring components
grafana:
  enabled: false
alertmanager:
  enabled: false
kubeControllerManager:
  enabled: false
kubeScheduler:
  enabled: false
...

# Disable auto service monitors and role creation
prometheusOperator:
  prometheusConfigReloader:
    enableProbe: false
  createCustomResource: false
  admissionWebhooks:
    enabled: false
  cleanupCustomResource: false
  rbac:
    create: false
```

The crucial part present in this instance is the `additionalScrapeConfigs` under
the `prometheusSpec` section, that defines the instances to scrape from:

```yaml
prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
     - job_name: 'federate'
        honor_labels: true
        metrics_path: '/federate'
        params:
          'match[]':
            - '{__name__!=""}'
        static_configs:
          - targets:
            - 'prometheus-federate-kube-p-prometheus.prometheus-federate.svc.cluster.local:9090'
            - '172.18.0.120:9090'
            - '172.18.0.140:9090'
```

Note that:

- The `match[]` param is populated with just `{__name__!=""}` that represents
  "every metric". It could have been something more specific, like:

  ```yaml
          params:
          'match[]':
            - '{__name__=~"node_.*"}'
            - '{__name__=~"kube_.*"}'
            - '{__name__=~"container_.*"}'
            - '{job="kubernetes-apiservers"}'
            - 'up'
  ```

- The `targets` section uses the internal DNS name for the local federated
  cluster, and the exposed IP for the other two instances.

The command to install this instance is the same as the previous, with a
different `--values` file:

```console
$ kubectl config use-context kind-ctlplane
Switched to context "kind-ctlplane".

$ helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --version ${PROMETHEUS_HELM_CHART} \
  --namespace prometheus \
  --create-namespace \
  --values helm-prometheus-ctlplane.yml
Release "prometheus" does not exist. Installing it now.
NAME: prometheus
...
STATUS: deployed
...
```

This service will be exposed at the `172.18.0.100` IP:

```console
$ kubectl --context kind-ctlplane --namespace prometheus \
    expose service prometheus-kube-prometheus-prometheus \
    --name prometheus-kube-prometheus-prometheus-lb \
    --type LoadBalancer \
    --load-balancer-ip 172.18.0.100
service/prometheus-kube-prometheus-prometheus-lb exposed
```

## Prometheus queries

By pointing the collector address at [http://172.18.0.100:9090](http://172.18.0.100:9090)
using a browser or a combination of `curl` and `jq` (to parse JSON output) it
is possible to get the metrics from all the targets. Here are some examples.

To get the health status of the configured targets:

```console
$ curl -s http://172.18.0.100:9090/api/v1/targets | jq '
  .data.activeTargets[]
  | select(.labels.job == "federate")
  | {
      instance: .discoveredLabels.__address__,
      health: .health,
      lastScrape: .lastScrapeDuration
    }'
...
```

This will result in something like:

```json
{
  "instance": "prometheus-federate-kube-p-prometheus.prometheus-federate.svc.cluster.local:9090",
  "health": "up",
  "lastScrape": 0.27405101
}
{
  "instance": "172.18.0.120:9090",
  "health": "up",
  "lastScrape": 0.255926875
}
{
  "instance": "172.18.0.140:9090",
  "health": "up",
  "lastScrape": 0.263927892
}
```

To get the list of distinct cluster label values scraped by Prometheus:

```console
$ curl -s "http://172.18.0.100:9090/api/v1/label/cluster/values" | jq
...
```

Will result in:

```json
{
  "status": "success",
  "data": [
    "ctlplane",
    "prod",
    "test"
  ]
}
```

To get the number of pods for each namespace on each cluster:

```console
$ curl -s "http://172.18.0.100:9090/api/v1/query?query=count%20by%20(cluster%2C%20namespace)%20(kube_pod_info)" | \
    jq -r '.data.result[] | [.metric.cluster, .metric.namespace, .value[1]] | @tsv'
...
```

Result will be something like:

```console
test    kube-system     8
test    prometheus-federate     4
test    metallb-system  2
test    local-path-storage      1
ctlplane        kube-system     8
ctlplane        prometheus-federate     4
ctlplane        metallb-system  2
ctlplane        local-path-storage      1
ctlplane        prometheus      2
prod    kube-system     8
prod    prometheus-federate     4
prod    metallb-system  2
prod    local-path-storage      1
```

Any of these queries can be reproduced on the web interface, and with any
frontend, like Grafana, pointing to the Prometheus collector instance.
