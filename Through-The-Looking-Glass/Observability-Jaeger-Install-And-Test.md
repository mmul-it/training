# Lab | Manual test a Jaeger instance

Simulate a frontend/backend application traces.

## The Jaeger installation

Jaeger can be deployed under Kubernetes, using Helm.

Follow: [https://medium.com/@blackhorseya/deploying-opentelemetry-and-jaeger-with-helm-on-kubernetes-d86cc8ba0332]()

```console
$ helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
"jaegertracing" has been added to your repositories

$ helm repo update
...
Update Complete. ⎈Happy Helming!⎈

$ helm upgrade --install jaeger jaegertracing/jaeger --namespace jaeger --create-namespace --values helm/helm-jaeger-ctlplane.yml
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
$ kubectl -n jaeger expose svc jaeger-collector \
    --name=jaeger-collector-lb \
    --type=LoadBalancer \
    --load-balancer-ip=172.18.0.109
service/jaeger-collector-lb exposed

$ kubectl -n jaeger expose svc jaeger-query \
    --name=jaeger-query-lb \
    --type=LoadBalancer \
    --load-balancer-ip=172.18.0.110
service/jaeger-query-lb exposed
```

## Test manually

Testing the Jaeger instance is possible with a simple `curl` command, by using
the `send-traces-to-Jaeger-via-curl.sh:

```console
$ ./send-traces-to-Jaeger-via-curl.sh 
SUCCESS. Trace DE8385685F7492CF sent to 172.18.0.109:9411.
```

The results can be seen inside the Jaeger web interface by selecting one of the
service `fronted-app` or `backend-service`, and depending on that the operation
that will be `frontend-processing` or `backend-processing`, and optionally
adding the tag `component=http-client` or `component=http-server`.

Note that everytime the script will be launched a new set of trace and spans
will be generated.
