# Lab | Configure and install Tempo

This lab will install and configure a Tempo instance inside the three Kubernetes
Kind clusters created in [Kubernetes-Install-3-Kind-Clusters.md](../../Common/Kubernetes-Install-3-Kind-Clusters.md).

## Preparation

The Helm chart used to install Tempo is available at [https://grafana.github.io/helm-charts]()
and can be configured locally as follows:

```console
$ helm repo add helm repo add grafana https://grafana.github.io/helm-charts
"grafana" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "grafana" chart repository
Update Complete. ⎈Happy Helming!⎈
```

A pre filled Helm values file should be locally downloaded from this repository:

- [helm/helm-tempo-ctlplane.yml]()


## Tempo Installation

The Helm values file contains specific configuration for the Tempo instance,
specifically:

```yaml
tempo:
  # This makes grafana Traces drilldown work
  metricsGenerator:
    enabled: true

traces:
  # This is used by Stage 3 python app (OTLP)
  otlp:
    http:
      enabled: true
    grpc:
      enabled: true
  # This is used by Stage 2 python app (jaeger-client)
  jaeger:
    thrift_http:
      enabled: true
```

In this configuration:

- `tempo` enables the `metricsGenerator` component, that will make Grafana
  interface work better with the traces.
- `traces` will enable the different protocols supported by the instance:
  - `otlp`, both for gRPC and HTTP.
  - `jaeger`, for Thrift over HTTP.

One way to install the Tempo chart is using the `helm upgrade --install`
command:

```console
$ kubectl config use-context kind-ctlplane
Switched to context "kind-ctlplane".

$ helm upgrade --install tempo grafana/tempo \
    --version ${TEMPO_HELM_CHART} \
    --namespace tempo \
    --create-namespace \
    --values helm-tempo-ctlplane.yml
...
```

## Tempo Exposition

There's only one service to be exposed, named `tempo`:

```console
kubectl --namespace tempo expose service tempo \
  --name tempo-lb \
  --type LoadBalancer \
  --load-balancer-ip 172.18.0.102
service/tempo-lb exposed
```

The `172.18.0.102` IP and will listen to many ports, since the kind of Tempo
installation is "all-in-one":

- `6831` (UDP): Jaeger agent – receives spans using Thrift over UDP (from Jaeger
  clients).
- `6832` (UDP): Jaeger agent (compact thrift) – for binary Thrift over UDP.
- `3200` (TCP): Tempo query frontend – used to query traces via the Tempo API or
  Grafana.
- `14268` (TCP): Jaeger collector (Thrift over HTTP) – accepts spans via HTTP
  POST from Jaeger clients.
- `14250` (TCP): Jaeger collector (gRPC) – accepts spans via the Jaeger gRPC
  protocol.
- `9411` (TCP): Zipkin ingestion – accepts spans in Zipkin format via HTTP.
- `55680` (TCP): OTLP (HTTP/1, legacy) – deprecated OTLP trace ingestion over
  HTTP.
- `55681` (TCP): OTLP (gRPC, legacy) – deprecated OTLP ingestion via gRPC.
- `4317` (TCP): OTLP (gRPC) – standard OTLP trace ingestion over gRPC.
- `4318` (TCP): OTLP (HTTP) – standard OTLP trace ingestion over HTTP.
- `55678` (TCP): OpenCensus receiver – used for ingesting traces from OpenCensus
  agents/exporters.

These ports will be used as reference for further OpenTelemetry labs.
