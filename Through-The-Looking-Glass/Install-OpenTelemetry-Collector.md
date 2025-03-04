# Install opentelemetry-collector

The `opentelemetry-collector` component installation can be done by using
`helm`:

```console
$ helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
"open-telemetry" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "open-telemetry" chart repository
...Successfully got an update from the "prometheus-community" chart repository
...Successfully got an update from the "grafana" chart repository
Update Complete. ⎈Happy Helming!⎈
```

Then a values file, named `helm-opentelemetry-collector.yml`, will define the
`opentelemetry-collector` configuration as follows:

```yaml
mode: deployment

image:
  repository: "otel/opentelemetry-collector"

config:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
    prometheus:
      config:
        scrape_configs:
          - job_name: 'otel-collector-metrics'
            static_configs:
              - targets: ['prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090']  # Adjust this to the appropriate target

  processors:
    batch:
      timeout: 5s
      send_batch_size: 1024

  exporters:
    # Tempo
    otlp/tempo:
      endpoint: "tempo-distributor.tempo-system.svc.cluster.local:4317"
      tls:
        insecure: true
    # Loki
    otlphttp/loki:
      endpoint: "http://loki-gateway.loki.svc.cluster.local/otlp"
      tls:
        insecure: true

  service:
    pipelines:
      traces:
        receivers: [otlp]
        processors: [batch]
        exporters: [otlp/tempo]
#      metrics:
#        receivers: [prometheus]
#        processors: [batch]
#        exporters: [otlp]  # Metrics are now being exported to OTLP for Prometheus to scrape
      logs:
        receivers: [otlp]
        processors: [batch]
        exporters: [otlphttp/loki]  # Logs are exported using OTLP HTTP to Loki
```

Finally the chart can be installed:

```console
$ helm install otel-collector open-telemetry/opentelemetry-collector \
        --create-namespace \
        --namespace otel-collector \
        -f helm-opentelemetry-collector.yml
NAME: my-otel-collector
LAST DEPLOYED: Tue Mar  4 14:25:10 2025
NAMESPACE: otel-collector
STATUS: deployed
REVISION: 1
...
```

And the service exposed:

```console
$ kubectl -n otel-collector expose service --name otel-collector-lb --type LoadBalancer otel-collector-opentelemetry-collector
service/otel-collector-lb exposed
```

To get the assigned IP just query it:

```console
$ kubectl -n otel-collector get svc otel-collector-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
172.18.0.105
```

## To be done

Fix the metrics part.
