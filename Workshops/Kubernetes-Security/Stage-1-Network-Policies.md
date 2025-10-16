# Kubernetes Network Policies

Network Policies work in Kubernetes at application level and help you to control
traffic flow at the IP address or port level for TCP, UDP, and SCTP protocols.

Check [the official Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/#network-traffic-filtering)
to catch all the details about these components.

## Requisites

Network Policies must be supported by the network plugin. In Minikube, by
default, there is no such kind of support, and so Minikube should be started by
using a different network plugin, like Calico:

```console
$ minikube stop && minikube delete && minikube start --cni=calico
* Stopping node "minikube"  ...
* Powering off "minikube" via SSH ...
* 1 node stopped.
* Deleting "minikube" in docker ...
* Deleting container "minikube" ...
* Removing /home/kirater/.minikube/machines/minikube ...
* Removed all traces of the "minikube" cluster.
* minikube v1.37.0 on Almalinux 9.4 (kvm/amd64)
* Automatically selected the docker driver. Other choices: none, ssh
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.48 ...
* Creating docker container (CPUs=2, Memory=3900MB) ...
* Preparing Kubernetes v1.34.0 on Docker 28.4.0 ...
* Configuring Calico (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: default-storageclass, storage-provisioner
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

## Network Policies with namespaces

Given a situation where you have these three namespaces:

kubectl delete namespace backend frontend external

```console
$ kubectl create namespace backend
namespace "backend" created

$ kubectl create namespace frontend
namespace "frontend" created

$ kubectl create namespace external
namespace "external" created
```

And inside the `backend` namespace you have a deployment with a listening
service, in this case `nginx`:

```console
$ kubectl --namespace backend create deployment backend --image nginx:latest
deployment backend created

$ kubectl wait --namespace backend --for=condition=ready pod --selector=app=backend --timeout=90s
pod/backend-86565945bf-xqxdr condition met
```

By creating two other applications on the other two namespaces you can simulate
connections coming from different places:

```console
$ kubectl -n frontend run frontend --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"
pod/frontend created

$ kubectl -n external run external --image=curlimages/curl:latest --restart=Never -- /bin/sh -c "while true; do sleep 3600; done"
pod/external created
```

Once you get the backend POD IP address and the name of the two client PODs:

```console
$ BACKENDIP=$(kubectl -n backend get pod -l app=backend -o jsonpath="{.items[0].status.podIP}")
(no output)

$ FRONTENDPOD=$(kubectl -n frontend get pod -l run=frontend -o jsonpath='{.items[0].metadata.name}')
(no output)

$ EXTERNALPOD=$(kubectl -n external get pod -l run=external -o jsonpath='{.items[0].metadata.name}')
(no output)
```

You can check what is the behavior without a Network Policy, so that the
connections should work for both clients:

```console
$ kubectl -n frontend exec -it $FRONTENDPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
REACHABLE

$ kubectl -n external exec -it $EXTERNALPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
REACHABLE
```

Then, to test Network Policies, each namespace should get a label, as follows:

```console
$ kubectl label namespace backend name=backend
namespace/backend labeled

$ kubectl label namespace frontend name=frontend
namespace/frontend labeled

$ kubectl label namespace external name=external
namespace/external labeled
```

And then it will be possible to create a Network Policy that will allow just the
connections coming from the `frontend` labeled namespace:

```console
$ kubectl create -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-except-frontend
  namespace: backend
spec:
  podSelector: {}  # applies to all pods in the backend namespace
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
EOF
```

A new test should confirm that now only `frontend` PODs are able to access
`$BACKENDIP`:

```console
$ kubectl -n frontend exec -it $FRONTENDPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
REACHABLE

$ kubectl -n external exec -it $EXTERNALPOD -- curl -s --connect-timeout 5 $BACKENDIP > /dev/null 2>&1 && echo REACHABLE || echo UNREACHABLE
UNREACHABLE
```

## Testing everything

The script `stage-1-network-policies-namespaces.sh` will make it possible to
test, check and clean the described configuration, as follows:

```console
$ ./stage-1-network-policies-namespaces.sh
namespace/backend created
namespace/frontend created
namespace/external created
deployment.apps/backend created
pod/backend-86565945bf-lmzgn condition met
pod/frontend created
pod/external created
Before NetworkPolicy (frontend): REACHABLE
Before NetworkPolicy (external): REACHABLE
namespace/frontend labeled
namespace/backend labeled
namespace/external labeled
networkpolicy.networking.k8s.io/deny-all-except-frontend created
After NetworkPolicy (frontend): REACHABLE
After NetworkPolicy (external): UNREACHABLE
```

The output demonstrates that **before** applying the Network Policies all the
communications between `frontend`, `external` and `backend` are allowed, and
right after, just `frontend` is able to contact `backend`.

Note that to make this work **namespaces must be labeled**.

All the resources can be queried, and when you're done everything can be cleaned
with:

```console
$ ./stage-1-network-policies-namespaces.sh clean
Cleaning up things...
namespace "backend" deleted
namespace "frontend" deleted
namespace "external" deleted
```
