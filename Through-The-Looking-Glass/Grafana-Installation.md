# Lab | Configure and install Grafana

This lab will install and configure a Grafana instance inside the three Kubernetes
Kind clusters created in [Kubernetes-Install-3-Kind-Clusters.md](../../Common/Kubernetes-Install-3-Kind-Clusters.md).

## Preparation

The Helm chart used to install Grafana is available at [https://grafana.github.io/helm-charts]()
and can be configured locally as follows:

```console
$ helm repo add grafana https://grafana.github.io/helm-charts
"grafana" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "grafana" chart repository
Update Complete. ⎈Happy Helming!⎈
```

A pre filled Helm values file should be locally downloaded from this repository:

- [helm/helm-grafana-ctlplane.yml]()

## Grafana Installation

The Helm values file contains specific configuration for the Grafana instance,
with a detailed configuration for each of the three datasources that will be
used inside the lab:

```yaml
datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: loki
        uid: dsloki
        type: loki
        access: proxy
        url: http://loki-gateway.loki.svc.cluster.local:80
        jsonData:
          derivedFields:
            - datasourceUid: dstempo
              matcherRegex: "trace_id"
              matcherType: label
              name: "Trace"
              url: "$${__value.raw}"
              urlDisplayLabel: "Trace"
      - name: prometheus
        uid: dsprometheus
        type: prometheus
        access: proxy
        url: http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090
        isDefault: true
        datasources.yamljsonData:
          exemplarTraceIdDestinations:
            - datasourceUid: dstempo
              name: trace_id
          httpMethod: POST
      - name: tempo
        uid: dstempo
        type: tempo
        access: proxy
        url: http://tempo.tempo.svc.cluster.local:3200
        jsonData:
          tracesToLogsV2:
            customQuery: false
            datasourceUid: dsloki
            filterByTraceID: true
            tags:
              - key: trace_id
                value: Trace ID
          tracesToMetrics:
            datasourceUid: dsprometheus
            queries: []
            tags:
              - key: trace_id
                value: Trace ID
```

In this configuration:

- `datasources` section under `datasources.yaml` -> `datasources` contains the
  three datasources associated to the three telemetry pillars previously
  installed:
  - **Loki**, pointing the instance `http://loki-gateway.loki.svc.cluster.local:80`.
  - **Tempo**, pointing the instance `http://tempo.tempo.svc.cluster.local:3200`.
  - **Prometheus**, pointing the instance `http://prometheus-kube-prometheus-prometheus.prometheus.svc.cluster.local:9090`
  Note that configuration is based upon services named with their _fully
  qualified domain name_, because we're operating in the same Kubernetes
  instance.
- Each datasource is associated with the others so that the correlation derived
  from the `trace_id` will make it possible to create links and references in
  Grafana's dashboards.

One way to install the Grafana chart is using the `helm upgrade --install`
command:

```console
$ kubectl config use-context kind-ctlplane
Switched to context "kind-ctlplane".

$ helm upgrade --install grafana grafana/grafana \
    --namespace grafana \
    --create-namespace \
    --values helm-grafana-ctlplane.yml
...
```

## Grafana Exposition

To expose Grafana web interface, the `3000` TCP port of the `grafana` deployment
needs to be targeted with the `80`, in a service named `grafana-lb`:

```console
$ kubectl --namespace grafana expose deployment grafana \
    --name grafana-lb \
    --port 80 \
    --target-port 3000 \
    --type LoadBalancer \
    --load-balancer-ip 172.18.0.105
service/grafana-lb exposed
```

Using a browser it will be possible to reach the `172.18.0.105` IP and to log
into the Grafana web interface by using the user `admin` and getting the
password inside the secret named `grafana`, in this way:

```console
$  kubectl get secret --namespace grafana grafana \
     -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
n1AfGnbDShQMpUO0gYCflMIO8QGzcDx45xjVI44h
```

After the first login, inside the `Connections` -> `Data sources` each one of
the three data sources can be verified by clicking on it and pushing the `Test`
button.

If everything went fine, the page will show the message "**Data source
successfully connected.**".

More detailed instructions about manual data source configurations are available
in the [Grafana-Datasources-Configuration.md]() document.

The Grafana web interface will be used as reference for further OpenTelemetry
labs.
