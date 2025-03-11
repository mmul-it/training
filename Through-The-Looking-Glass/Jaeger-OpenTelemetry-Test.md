# Lab | Manual test a Jaeger instance

## The Jaeger installation

Jaeger can be deployed under Kubernetes, using Helm.

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
```

To access the service from the outside, a `LoadBalancer` service should be
created:

```console
$ kubectl -n jaeger expose svc jaeger-query --name=jaeger-query-lb --type=LoadBalancer
service/jaeger-query-lb exposed

$ kubectl -n jaeger get svc jaeger-query-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}'
172.18.0.104:16686

$ kubectl -n jaeger expose svc jaeger-collector --name=jaeger-collector-lb --type=LoadBalancer
service/jaeger-collector-lb exposed

$ kubectl -n jaeger get svc jaeger-collector-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}'
172.18.0.105:9411
```

## Test manually

Testing the Jaeger instance is possible With the `otel-cli` tool:

```console
$ go install github.com/equinix-labs/otel-cli@latest
...

$ export OTEL_EXPORTER_OTLP_ENDPOINT=http://172.18.0.105:4318/v1/traces

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

The results can be seen inside the Jaeger web interface.
