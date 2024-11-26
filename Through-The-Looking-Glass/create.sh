cat <<EOF > kind-argo-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 6443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
EOF

cat <<EOF > kind-test-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 7443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
EOF

cat <<EOF > kind-prod-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 8443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
EOF

kind create cluster --name argo --config kind-argo-config.yml
kind create cluster --name test --config kind-test-config.yml
kind create cluster --name prod --config kind-prod-config.yml

for K8S in argo test prod; do
  kubectl --context kind-$K8S get nodes; echo
  kubectl get configmap kube-proxy -n kube-system -o yaml | sed -e "s/strictARP: false/strictARP: true/" | kubectl apply -f - -n kube-system
  export METALLB_VERSION='v0.14.8'
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml
  kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
done

cat <<EOF > kind-argo-metallb-pools.yml
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

cat <<EOF > kind-test-metallb-pools.yml
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

cat <<EOF > kind-prod-metallb-pools.yml
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

for K8S in argo test prod; do
  kubectl apply -f kind-$K8S-metallb-pools.yml
done

kubectl config use-context kind-argo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

kubectl config use-context kind-test
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
kubectl -n monitoring expose service prometheus-kube-prometheus-prometheus --name=prometheus-kube-prometheus-prometheus-lb --type=LoadBalancer
PROMETHEUS_PROM_TEST=$(kubectl -n monitoring get svc prometheus-kube-prometheus-prometheus-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ${PROMETHEUS_PROM_TEST}
kubectl -n monitoring expose service prometheus-kube-prometheus-alertmanager --name=prometheus-kube-prometheus-alertmanager-lb --type=LoadBalancer
PROMETHEUS_ALERT_TEST=$(kubectl -n monitoring get svc prometheus-kube-prometheus-alertmanager-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ${PROMETHEUS_ALERT_TEST}

kubectl config use-context kind-prod
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
kubectl -n monitoring expose service prometheus-kube-prometheus-prometheus --name=prometheus-kube-prometheus-prometheus-lb --type=LoadBalancer
PROMETHEUS_PROM_PROD=$(kubectl -n monitoring get svc prometheus-kube-prometheus-prometheus-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ${PROMETHEUS_PROM_PROD}
kubectl -n monitoring expose service prometheus-kube-prometheus-alertmanager --name=prometheus-kube-prometheus-alertmanager-lb --type=LoadBalancer
PROMETHEUS_ALERT_PROD=$(kubectl -n monitoring get svc prometheus-kube-prometheus-alertmanager-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}')
echo ${PROMETHEUS_ALERT_PROD}
