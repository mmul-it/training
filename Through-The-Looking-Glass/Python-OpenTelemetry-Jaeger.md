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
