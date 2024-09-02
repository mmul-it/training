# Lab | Install, configure and use MetalLB operator

In this lab you will install, configure and create the custom resources from
the MetalLB operator.

## Operator's requirements

To enable the Kubernetes cluster properly support MetalLB, the `ipvs`
configuration of the `KubeProxyConfiguration` resource needs to have the
`strictARP` setting to true (check the [MetalLB offical documentation](https://metallb.universe.tf/installation/#preparation)).

This is a one command operation:

```console
$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
configmap/kube-proxy configured
```

It is now time to install the operator.

## Operator's initialization

Installation can be made directly by pointing to the GitHub's yaml:

```console
$ export METALLB_VERSION='v0.13.11'

$ kubectl create -f https://raw.githubusercontent.com/metallb/metallb-operator/${METALLB_VERSION}/bin/metallb-operator.yaml
namespace/metallb-system created
...
clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker created
```

This will enable MetalLB Custom Resources, managed by the operator:

```console
$ kubectl get customresourcedefinitions.apiextensions.k8s.io | grep .metallb.io
addresspools.metallb.io        2023-11-28T10:21:29Z
bfdprofiles.metallb.io         2023-11-28T10:21:29Z
bgpadvertisements.metallb.io   2023-11-28T10:21:29Z
bgppeers.metallb.io            2023-11-28T10:21:29Z
communities.metallb.io         2023-11-28T10:21:29Z
ipaddresspools.metallb.io      2023-11-28T10:21:29Z
l2advertisements.metallb.io    2023-11-28T10:21:29Z
metallbs.metallb.io            2023-11-28T10:21:29Z
```

The status of the `metallb-system` namespace after the installation will be
similar to this:

```console
$ kubectl -n metallb-system get all
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/metallb-operator-controller-manager-7c46d89759-jrbdz   1/1     Running   0          15m
pod/metallb-operator-webhook-server-7ccc476797-rjxdk       1/1     Running   0          15m

NAME                                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/metallb-operator-webhook-service   ClusterIP   10.100.3.165    <none>        443/TCP   15m
service/webhook-service                    ClusterIP   10.109.218.40   <none>        443/TCP   15m

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/metallb-operator-controller-manager   1/1     1            1           15m
deployment.apps/metallb-operator-webhook-server       1/1     1            1           15m

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/metallb-operator-controller-manager-7c46d89759   1         1         1       15m
replicaset.apps/metallb-operator-webhook-server-7ccc476797       1         1         1       15m
```

### Recent MetalLB versions and node labels

A change applied in the `0.14.*` versions of MetalLB checks for the presence (or
not) of a specific label named `exclude-from-external-load-balancers` on the
nodes, and if it is present IP advertisment (and so the load balancer itself)
will not work.

To check if the label is present on the nodes use `kubectl`:

```console
$ kubectl get nodes --selector=node.kubernetes.io/exclude-from-external-load-balancers
NAME              STATUS   ROLES           AGE   VERSION
training-kfs-01   Ready    control-plane   55m   v1.30.4
training-kfs-02   Ready    control-plane   55m   v1.30.4
training-kfs-03   Ready    control-plane   54m   v1.30.4
```

Since this lab is an hyperconverged one, where nodes act both as control-plane
and workers, it is safe to remove that label to make MetalLB work properly:

```console
$ for node in $(kubectl get nodes --selector=node.kubernetes.io/exclude-from-external-load-balancers -o name); do \
    kubectl label $node node.kubernetes.io/exclude-from-external-load-balancers-; \
  done
node/training-kfs-01 unlabeled
node/training-kfs-02 unlabeled
node/training-kfs-03 unlabeled
```

For more details about this, check [this GitHub issue in the MetalLB project](https://github.com/metallb/metallb-operator/issues/490).

## Activate MetalLB instance

To activate MetalLB functionalities a `MetalLB` Custom resource must be created:

```console
$ cat << EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: MetalLB
metadata:
  name: metallb
  namespace: metallb-system
EOF
```

This will initialize the MetalLB resources that will manage all the
functionalities:

```console
$ kubectl -n metallb-system get pods
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/controller-85d8bf7b75-v9tng                            1/1     Running   0          5m31s
pod/metallb-operator-controller-manager-7c46d89759-jrbdz   1/1     Running   0          22m
pod/metallb-operator-webhook-server-7ccc476797-rjxdk       1/1     Running   0          22m
pod/speaker-c9ssg                                          1/1     Running   0          5m31s
pod/speaker-ch6dv                                          1/1     Running   0          5m31s
pod/speaker-jrjjf                                          1/1     Running   0          5m31s
```

### Configure IP Pools

To specify the pool of IP addresses that can be allocated to LoadBalancer
services an `IPAddressPool` resource needs to be created:

```console
$ cat << EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mypool1
  namespace: metallb-system
spec:
  addresses:
  - 192.168.99.220-192.168.99.230
EOF
```

### Configure L2Advertisement

The last bit needed to complete the configuration is to enable the advertisement
capabilities of the LoadBalancer service, and can be achieved by creating an
`L2Advertisement` Custom Resource:

```console
$ cat << EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mypool1
  namespace: metallb-system
spec:
  ipAddressPools:
  - mypool1
EOF
```

This will enable the configured pool to be advertised inside the destination
network.

## Test MetalLB

MetalLB can be tested with a `namespace` with a `deployment`:

```console
$ kubectl create namespace myns
namespace/myns created

$ kubectl -n myns create deployment nginx --image nginx:latest --port 80
deployment.apps/nginx created
```

And then by exposing the application, using the `LoadBalancer` type:

```console
$ kubectl -n myns expose deployment nginx --name nginx --type LoadBalancer --port 80 --target-port 80
service/nginx exposed
```

This will produce a service with an IP that will be part of the reserved pool:

```console
$ kubectl -n myns get services
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
nginx   LoadBalancer   10.110.130.230   192.168.99.220   80:30265/TCP   28m
```

That should be reachable on the network and available for direct requests:

```console
$ curl -s 192.168.99.220 | grep Welcome
<title>Welcome to nginx!</title>
<h1>Welcome to nginx!</h1>
```
