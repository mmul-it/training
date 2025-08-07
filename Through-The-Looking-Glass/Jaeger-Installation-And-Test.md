# Lab | Manual test a Jaeger instance

Simulate a frontend/backend application traces using Jaeger.

## Preparation

The Helm chart used to install Jaeger are available at [https://jaegertracing.github.io/helm-charts]()
and can be configured locally as follows:

```console
$ helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
"jaegertracing" has been added to your repositories

$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "jaegertracing" chart repository
Update Complete. ⎈Happy Helming!⎈

```

A pre filled Helm values file should be locally downloaded from this repository:

- [helm/helm-jaeger-ctlplane.yml]()

This will configure Jaeger with essential services.

An additional script, named [scripts/send-traces-to-Jaeger-via-curl.sh]() will
be used to test traces shipment to the Jaeger instance.

## The Jaeger installation

This command will install Jaeger under Kubernetes using Helm with the previously
downloaded values file:

```console
$ export JAEGER_HELM_CHART='3.4.1'
(no output)

$ helm upgrade --install jaeger jaegertracing/jaeger \
    --version ${JAEGER_HELM_CHART} \
    --namespace jaeger \
    --create-namespace \
    --values helm-jaeger-ctlplane.yml
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

To access the service from the outside, two `LoadBalancer` services should be
created, one related to the `jaeger-collector` (port 9411), where the traces
will be sent, the other related to the `jaeger-query` (port 16686), that will
be accessed for the queries:

```console
$ kubectl --namespace=jaeger expose svc jaeger-collector \
    --name jaeger-collector-lb \
    --type LoadBalancer \
    --load-balancer-ip 172.18.0.109
service/jaeger-collector-lb exposed

$ kubectl --namespace=jaeger expose svc jaeger-query \
    --name jaeger-query-lb \
    --type LoadBalancer \
    --load-balancer-ip 172.18.0.110
service/jaeger-query-lb exposed
```

## Test manually

Testing the Jaeger instance is possible with a simple `curl` command, by using
the `scripts/send-traces-to-Jaeger-via-curl.sh` script:

```console
$ ./scripts/send-traces-to-Jaeger-via-curl.sh
SUCCESS. Trace DE8385685F7492CF sent to 172.18.0.109:9411.
```

The results can be seen inside the Jaeger web interface by selecting one of the
service `fronted-app` or `backend-service`, and depending on that the operation
that will be `frontend-processing` or `backend-processing`, and optionally
adding the tag `component=http-client` or `component=http-server`.

Note that everytime the script will be launched a new set of trace and spans
will be generated.
