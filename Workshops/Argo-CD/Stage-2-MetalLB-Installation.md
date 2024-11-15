# Argo CD Workshop - Stage 2

A number of services will be exposed inside the Kind default subnet,
specifically:

- The Argo CD interface on the `kind-argo` cluster, with the `172.18.0.100` IP.
- The deployment on the `kind-test` cluster, with the `172.18.0.120` IP.
- The deployment on the `kind-prod` cluster, with the `172.18.0.140` IP.

Each cluster will expose an IP for the services using [MetalLB](https://metallb.universe.tf/).

## Configure MetalLB on kind-argocd

Installing MetalLB is a pretty straightforward process (note that `StrictARP`
must be enabled on the `kube-proxy` ConfigMap), starting from `kind-argo`:

```console
$ kubectl config use-context kind-argo
Switched to context "kind-argo".

$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
Warning: resource configmaps/kube-proxy is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/kube-proxy configured

$ export METALLB_VERSION='v0.14.8'
(no output)

$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
namespace/metallb-system created
...
...
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration created
```

MetalLB installation will take a while to complete, so before proceeding it is
good to wait until it completes:

```console
$ kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
pod/controller-756c6b677-nrxgz condition met
pod/speaker-62ws5 condition met
```

To define the IP range that the MetalLB load balancer will assign two Kubernetes
resources should be created, the `IPAddressPool` and the `L2Advertisement`
(check [kind-argo-metallb-pools.yml](kind-argo-metallb-pools.yml)):

```console
$ cat <<EOF > kind-argo-metallb-pools.yml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mypool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.0.100-172.18.0.110
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mypool
  namespace: metallb-system
spec:
  ipAddressPools:
  - mypool
EOF

$ kubectl apply -f kind-argo-metallb-pools.yml
ipaddresspool.metallb.io/mypool created
l2advertisement.metallb.io/mypool created
```

In this case `kind-argocd` will allocate IPs from `172.18.0.100` to `172.18.0.110`.

## Configure MetalLB on kind-test

Same exact process as before will enable MetalLB on `kind-test` cluster:

```console
$ kubectl config use-context kind-test
Switched to context "kind-test".

$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
Warning: resource configmaps/kube-proxy is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/kube-proxy configured

$ export METALLB_VERSION='v0.14.8'
(no output)

$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
namespace/metallb-system created
...
...
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration created

$ kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
pod/controller-756c6b677-vbr8m condition met
pod/speaker-wtmgf condition met
```

This time the load balancer IP range will be from `172.18.0.120` to `172.18.0.130`
(check [kind-test-metallb-pools.yml](kind-test-metallb-pools.yml)):

```console
$ cat <<EOF > kind-test-metallb-pools.yml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mypool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.0.120-172.18.0.130
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mypool
  namespace: metallb-system
spec:
  ipAddressPools:
  - mypool
EOF

$ kubectl apply -f kind-test-metallb-pools.yml
ipaddresspool.metallb.io/mypool created
l2advertisement.metallb.io/mypool created
```

## Configure MetalLB on kind-prod

The last cluster is `kind-prod`:

```console
$ kubectl config use-context kind-prod
Switched to context "kind-prod".

$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
Warning: resource configmaps/kube-proxy is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/kube-proxy configured

$ export METALLB_VERSION='v0.14.8'
(no output)

$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
namespace/metallb-system created
...
...
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration created

$ kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
pod/controller-756c6b677-znd5z condition met
pod/speaker-gjznh condition met
```

This time the IP range will be from `172.18.0.140` to `172.18.0.150`
(check [kind-prod-metallb-pools.yml](kind-prod-metallb-pools.yml)):

```console
$ cat <<EOF > kind-prod-metallb-pools.yml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: mypool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.0.140-172.18.0.150
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: mypool
  namespace: metallb-system
spec:
  ipAddressPools:
  - mypool
EOF

$ kubectl apply -f kind-prod-metallb-pools.yml
ipaddresspool.metallb.io/mypool created
l2advertisement.metallb.io/mypool created
```

It is finally possible to proceed with [Stage 3](Stage-3-Argo-CD-Installation.md).
