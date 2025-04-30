# Test Telemetry with Python - Stage 3

This is the third and last stage where a Python application writes and exposes
all the telemetry data to the OpenTelemetry Collector that will collect
everything in a standard way and distribute to the specific backends.

## Requirements

This stage requires OpenTelemetry Collector and Prometheus to be properly
installed and configured inside the Kubernetes control plane.

### OpenTelemetry Collector

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
        http:
          endpoint: 0.0.0.0:4318

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
    # Prometheus
    prometheus:
      endpoint: "0.0.0.0:9090"

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

Note the various configurations related to the `exporters`, the `services` and
the `ports` where the `9090` Prometheus port is exposed, so that the Kubernetes
Prometheus can scrape from it.

The chart can then be installed:

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

### Prometheus

The Prometheus instance needs to be configured to scrape from the
`otel-collector` instance, and as declared in the [helm-prometheus-ctlplane.yml](helm-prometheus-ctlplane.yml)
the specific configuration part is:

```yaml
grafana:
  enabled: false

alertmanager:
  enabled: false

prometheus:
  prometheusSpec:
    additionalScrapeConfigs:
...
      # This is used to scrape from the otel-collector exposed metrics
      - job_name: 'otel-collector'
        static_configs:
          - targets: ['otel-collector-opentelemetry-collector.otel-collector.svc.cluster.local:9090']
...
```

Note the usage of the internal `otel-collector` address, derived from the
Kubernetes service, so `otel-collector-opentelemetry-collector.otel-collector.svc.cluster.local:9090`.

Again, to be sure this is applied inside the existing Prometheus instance it is
sufficient to upgrade via `helm` the installation:

```console
$ helm upgrade prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --values helm-prometheus-ctlplane.yml
NAME: prometheus
LAST DEPLOYED: Fri Mar  7 11:42:58 2025
NAMESPACE: monitoring
STATUS: deployed
REVISION: 2
TEST SUITE: None
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=prometheus"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=prometheus" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

## Start stage 3 of the app

Nothing changes from the previous stages. After activating the Python
environment and getting into the `python-app` directory, launching the app is
just a matter of:

```console
$ ./launch.sh Stage-3-Otel
~/Git/kiratech/labs/Through-The-Looking-Glass/python-app/Stage-3-Otel ~/Git/kiratech/labs/Through-The-Looking-Glass/python-app
 * Serving Flask app 'alice'
 * Debug mode: on
 * Serving Flask app 'cheshire'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5000
Press CTRL+C to quit
 * Restarting with stat
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://172.18.0.1:5001
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 197-316-231
 * Debugger is active!
 * Debugger PIN: 197-316-231
```

The frontend application will, as usual, be listening at the [http://172.18.0.1:5000](http://172.18.0.1:5000)
address.

Note that since the scrape configuration for Prometheus on the stage 2
applications is still present, there will still be some `GET` actions, but this
time the result for them will be a 404, not found, because we're not exposing
anymore metrics this way (we're pushing them to the `otel-collector`):

```console
172.18.0.4 - - [07/Mar/2025 12:03:52] "GET /metrics HTTP/1.1" 404 -
172.18.0.4 - - [07/Mar/2025 12:03:56] "GET /metrics HTTP/1.1" 404 -
172.18.0.4 - - [07/Mar/2025 12:04:22] "GET /metrics HTTP/1.1" 404 -
172.18.0.4 - - [07/Mar/2025 12:04:26] "GET /metrics HTTP/1.1" 404 -
```

There is nothing to worry about these.

## Simulate traffic

To start testing the app let's use again the `simulate-traffic.sh`:

```console
$ ./simulate-traffic.sh
Starting traffic simulation...
Doing 47 parallel requests...
Doing 11 parallel requests...
Doing 40 parallel requests...
Doing 6 parallel requests...
Doing 48 parallel requests...
Doing 19 parallel requests...
Doing 9 parallel requests...
Doing 18 parallel requests...
...
```

Remember that the script will continue until the `Ctrl+C` key combination will
be pressed.

## Look at the results

This time the output logs will be limited to:

```console
...
...
192.168.1.50 - - [07/Mar/2025 12:07:14] "GET /process HTTP/1.1" 200 -
192.168.1.50 - - [07/Mar/2025 12:07:14] "GET / HTTP/1.1" 200 -
...
...
```

This happens because all the logs are sent to the collector, and just the GET
are stored to the standard output.

Agai, to check everything on the Grafana side look at the Data Sources:

- **Loki** for the logs.
- **Prometheus** for the metrics.
- **Tempo** for the traces.
