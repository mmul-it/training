# Python/OpenTelemetry/Jaeger examlple

This is part of the "**Through the looking glass**" observability course which will
explore these topics:

- Prometheus Metrics
- Elastic Logs
- Jeager Trace

This lab is about Jeager Trace.

## Prepare the environment

### The Python virtual env

Create the virtualenv and install requirements via `pip':

```console
$ pip install flask opentelemetry-api opentelemetry-sdk opentelemetry-instrumentation-flask opentelemetry-instrumentation-requests opentelemetry-exporter-otlp
...
```

### The frontend application

The code of the [Frontend application](cheshire.py).

### The backend application

The code of the [Backend application]().

### The Jaeger instance

The Jaeger instance can be a single container:

```console
$ docker run --rm --name jaeger \
    -p 16686:16686 \
    -p 4318:4318 \
    jaegertracing/all-in-one:1.63.0
...
```

## Test everything

In two different terminals, launch first the backend app:

```console
$ python cheshire.py
 * Serving Flask app 'cheshire'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5001
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 813-701-761
...
```

And then the frontend:

```console
$ python alice.py
 * Serving Flask app 'alice'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on http://127.0.0.1:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 813-701-761
...
```

Finally look call the [http://localhost:5000](http://localhost:5000) url and
then check the Jaeger web interface at [http://localhost:16686](http://localhost:16686)
to query the related traces.

## Add Tempo to Grafana

Tempo installation

```console
$ kubectl create namespace tempo-test

$ cat <<EOF > helm-tempo.yml
traces:
  otlp:
    http:
      enabled: true
    grpc:
      enabled: true
EOF

$ helm -n tempo-test install --values helm-tempo.yml tempo grafana/tempo-distributed

$ kubectl -n tempo-test expose service tempo-query-frontend --name=tempo-query-frontend-lb --type=LoadBalancer
$ eval "TEMPO_FRONTEND_${CTLP}=$(kubectl -n tempo-test get svc tempo-query-frontend-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
$ kubectl -n tempo-test expose service tempo-distributor --name=tempo-distributor-lb --type=LoadBalancer
$ eval "TEMPO_DISTRIB_${CTLP}=$(kubectl -n tempo-test get svc tempo-distributor-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')"
```

Now Jaeger should be instructed to send traces to Tempo, to make this possible
it's better to deploy it under Kubernetes, using Helm.

Follow: [https://medium.com/@blackhorseya/deploying-opentelemetry-and-jaeger-with-helm-on-kubernetes-d86cc8ba0332]()

```console
$ helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
"jaegertracing" has been added to your repositories

$ helm repo update
...
Update Complete. ⎈Happy Helming!⎈

$ cat <<EOF > helm-jaeger.yml
provisionDataStore:
  cassandra: false
allInOne:
  enabled: true
  extraEnv:
  - name: OTEL_EXPORTER_OTLP_ENDPOINT
    value: 'https://172.18.0.102:4317'
  - name: OTEL_EXPORTER_OTLP_INSECURE
    value: "true"
storage:
  type: memory
agent:
  enabled: false
collector:
  enabled: false
query:
  enabled: false
EOF

$ helm upgrade --install jaeger jaegertracing/jaeger --namespace jaeger --create-namespace --values helm-jaeger.yml
Release "jaeger" does not exist. Installing it now.
NAME: jaeger
LAST DEPLOYED: Thu Dec 12 10:48:04 2024
NAMESPACE: jaeger
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
###################################################################
### IMPORTANT: Ensure that storage is explicitly configured     ###
### Default storage options are subject to change.              ###
###                                                             ###
### IMPORTANT: The use of <component>.env: {...} is deprecated. ###
### Please use <component>.extraEnv: [] instead.                ###
###################################################################

You can log into the Jaeger Query UI here:

  export POD_NAME=$(kubectl get pods --namespace jaeger -l "app.kubernetes.io/instance=jaeger,app.kubernetes.io/component=query" -o jsonpath="{.items[0].metadata.name}")
  echo http://127.0.0.1:8080/
  kubectl port-forward --namespace jaeger $POD_NAME 8080:16686

$ kubectl -n jaeger expose svc jaeger-query --name=jaeger-query-lb --type=LoadBalancer
service/jaeger-query-lb exposed

$ kubectl -n jaeger get svc jaeger-query-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}'
172.18.0.104:16686

$ kubectl -n jaeger expose svc jaeger-collector --name=jaeger-collector-lb --type=LoadBalancer
service/jaeger-collector-lb exposed

$ kubectl -n jaeger get svc jaeger-collector-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}'
172.18.0.105:9411
```

Since, at the moment, there seems to be no way to send traces fro Jaeger to
Tempo, then it would be a lot easier to send traces directly from the apps into
Tempo, so that those can be further integrated with Loki.

This can be achieved by changing the Python scripts to point to the Tempo url:

```python
tempo_exporter = OTLPSpanExporter(
    endpoint = "172.17.0.2:4317",
    insecure = True
)
trace.get_tracer_provider().add_span_processor(BatchSpanProcessor(tempo_exporter))
```

Then it will be time to configure the Grafana datasource related to Tempo.

### Test manually

With `otel-cli`:

```console
$ go install github.com/equinix-labs/otel-cli@latest
...

$ export OTEL_EXPORTER_OTLP_ENDPOINT=http://172.18.0.102:4318/v1/traces

$ ~/go/bin/otel-cli span \
      --service "my-application" \
      --name "send data to the server" \
      --start $(date +%s.%N) \
      --end $(date +%s.%N) \
      --attrs "os.kernel=$(uname -r)" \
      --tp-print --verbose
# trace id: c21425cf2ff5b8a28bcb13822de30a4e
#  span id: ef02a2c9e04e24a7
TRACEPARENT=00-c21425cf2ff5b8a28bcb13822de30a4e-ef02a2c9e04e24a7-01
```
