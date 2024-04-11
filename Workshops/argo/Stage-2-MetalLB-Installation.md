# Argo CD Workshop - Stage 2

## Configure MetalLB to expose ArgoCD server

```console
$ kubectl config use-context kind-argo
Switched to context "kind-argo".

$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
Warning: resource configmaps/kube-proxy is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/kube-proxy configured

$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.4/config/manifests/metallb-native.yaml
namespace/metallb-system created
...
...
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration created

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

```console
$ kubectl config use-context kind-test
Switched to context "kind-test".

$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
Warning: resource configmaps/kube-proxy is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/kube-proxy configured

$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.4/config/manifests/metallb-native.yaml
namespace/metallb-system created
...
...
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration created

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

```console
$ kubectl config use-context kind-prod 
Switched to context "kind-prod".

$ kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
Warning: resource configmaps/kube-proxy is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
configmap/kube-proxy configured

$ kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.4/config/manifests/metallb-native.yaml
namespace/metallb-system created
...
...
validatingwebhookconfiguration.admissionregistration.k8s.io/metallb-webhook-configuration created

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
