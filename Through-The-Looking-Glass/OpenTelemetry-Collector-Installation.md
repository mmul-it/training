# Lab | Configure and install otel-collector

This lab will install and configure an OTel Collector instance inside the three
Kubernetes Kind clusters created in [Kubernetes-Install-3-Kind-Clusters.md](../../Common/Kubernetes-Install-3-Kind-Clusters.md).

## Preparation

The Helm chart used to install OTel Collector is available at [https://open-telemetry.github.io/opentelemetry-helm-charts]()
and can be configured locally as follows:

```console
$ helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
"open-telemetry" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "open-telemetry" chart repository
Update Complete. ⎈Happy Helming!⎈
```

A pre filled Helm values file should be locally downloaded from this repository:

- [helm/helm-otel-collector-ctlplane.yml]()

## OTel Collector Installation

The Helm values file contains specific configuration for the OTel Collector
pipelnes, specifically:

```yaml
mode: deployment

image:
  repository: "ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib"

config:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318

  processors:
    batch:
      timeout: 5s
      send_batch_size: 1024

  exporters:
    # Tempo
    otlp/tempo:
      endpoint: "tempo-distributor.tempo.svc.cluster.local:4317"
      tls:
        insecure: true
    # Loki
    otlphttp/loki:
      endpoint: "http://loki-gateway.loki.svc.cluster.local/otlp"
      tls:
        insecure: true
    # Prometheus
    prometheus:
      endpoint: "0.0.0.0:9090"
      enable_open_metrics: true

  service:
    pipelines:
      traces:
        receivers: [otlp]
        processors: [batch]
        exporters: [otlp/tempo]
      metrics:
        receivers: [otlp]
        processors: [batch]
        exporters: [prometheus]  # Metrics are now being exported to OTLP for Prometheus to scrape
      logs:
        receivers: [otlp]
        processors: [batch]
        exporters: [otlphttp/loki]  # Logs are exported using OTLP HTTP to Loki

ports:
  jaeger-compact:
    enabled: false
  jaeger-thrift:
    enabled: false
  jaeger-grpc:
    enabled: false
  zipkin:
    enabled: false
  metrics:
    enabled: true
    containerPort: 9090
    servicePort: 9090
    protocol: TCP
```

In this configuration:

- `receivers` accepts telemetry in OTLP format over gRPC and HTTP, standard ports.
- `processors` groups telemetry data into batches for efficient delivery every
  5 seconds or 1024 items.
- `exporters` send:
  - **Traces** to Tempo using OTLP over gRPC.
  - **Logs** to Loki via OTLP over HTTP.
  - **Metrics** exposed on /metrics for Prometheus to scrape.
- `service` defines three separate pipelines, one for each signal:
  - All receive via OTLP.
  - All process data using the batch processor.
  - Each exports to its corresponding backend.
- `ports` disables not used services, enables Prometheus `9090` and leave the
  ports related to the OTel protocol, so `4317` (gRPC) and `4318` (HTTP).

One way to install the OTel Collector is using the `helm upgrade --install`
command:

```console
$ kubectl config use-context kind-ctlplane
Switched to context "kind-ctlplane".

$ helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  --create-namespace \
  --namespace otel-collector \
  -f helm-otel-collector-ctlplane.yml
...
```

## OTel Collector Exposition

There's only one service to be exposed, `otel-collector-opentelemetry-collector`:

```console
$ kubectl --namespace otel-collector expose service otel-collector-opentelemetry-collector \
  --name otel-collector-lb \
  --type LoadBalancer \
  --load-balancer-ip 172.18.0.104
service/otel-collector-lb exposed
```

The `172.18.0.104` IP and will listen to three ports:

- `9090` which is the Prometheus Metrics exposition.
- `4317` which is the gRPC TCP port for the OpenTelemetry protocol.
- `4318` which is the HTTP TCP port for the OpenTelemetry protocol.

These ports will be used as reference for further OpenTelemetry labs.
