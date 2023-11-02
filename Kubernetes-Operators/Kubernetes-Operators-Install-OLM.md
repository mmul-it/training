# Lab | Install OLM to manage operators

## Prerequisites

You should have a running Kubernetes cluster. You can use a local cluster like
Minikube, a managed Kubernetes service like GKE, or any other Kubernetes
environment.

You need to have kubectl and kubectl-compatible Kubernetes configuration files.

## Install OLM using kubectl

Check [Adding OLM to Kubernetes](https://kubebyexample.com/learning-paths/operator-framework/operator-lifecycle-manager/adding-olm-kubernetes).

OLM can be installed using kubectl and the OLM installation manifest.
Here's how you can install the Custom Resources:

```bash
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/latest/download/crds.yaml --server-side=true
```

The `--server-side` option is needed because of [this bug](https://github.com/operator-framework/operator-lifecycle-manager/issues/2968).

This will be the expected output:

```console
customresourcedefinition.apiextensions.k8s.io/catalogsources.operators.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/clusterserviceversions.operators.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/installplans.operators.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/olmconfigs.operators.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/operatorconditions.operators.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/operatorgroups.operators.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/operators.operators.coreos.com serverside-applied
customresourcedefinition.apiextensions.k8s.io/subscriptions.operators.coreos.com serverside-applied
```

And then it will be possible to install OLM itself:

```bash
kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/latest/download/olm.yaml --server-side=true
```

That should produce this output:

```console
namespace/olm serverside-applied
namespace/operators serverside-applied
serviceaccount/olm-operator-serviceaccount serverside-applied
clusterrole.rbac.authorization.k8s.io/system:controller:operator-lifecycle-manager serverside-applied
clusterrolebinding.rbac.authorization.k8s.io/olm-operator-binding-olm serverside-applied
olmconfig.operators.coreos.com/cluster serverside-applied
deployment.apps/olm-operator serverside-applied
deployment.apps/catalog-operator serverside-applied
clusterrole.rbac.authorization.k8s.io/aggregate-olm-edit serverside-applied
clusterrole.rbac.authorization.k8s.io/aggregate-olm-view serverside-applied
operatorgroup.operators.coreos.com/global-operators serverside-applied
operatorgroup.operators.coreos.com/olm-operators serverside-applied
clusterserviceversion.operators.coreos.com/packageserver serverside-applied
catalogsource.operators.coreos.com/operatorhubio-catalog serverside-applie
```

## Verify OLM Operator Installation

To verify the OLM installation, check the OLM namespace and its pods:

```bash
kubectl get namespace olm
```

```console
NAME   STATUS   AGE
olm    Active   2m57s
```

You should see the OLM-related pods running in the "olm" namespace:

```bash
kubectl get pods -n olm
```

```console
NAME                                READY   STATUS    RESTARTS   AGE
catalog-operator-67dd8d46bc-mgmzk   1/1     Running   0          53s
olm-operator-7b9c8fd79-s29ns        1/1     Running   0          53s
operatorhubio-catalog-khf52         1/1     Running   0          46s
packageserver-6c796b94f5-8qshf      1/1     Running   0          46s
packageserver-6c796b94f5-btftb      1/1     Running   0          46s
```

Check the status of the OLM operator by running:

```bash
kubectl get csv -n olm
```

You should see the OLM operator's CSV in a "Succeeded" state, indicating a
successful installation:

```console
NAME            DISPLAY          VERSION   REPLACES   PHASE
packageserver   Package Server   0.18.3               Succeeded
```

## Prepare the environment to install the Trivy Operator

Check [Trivy Operator Lifecycle Manager](https://aquasecurity.github.io/trivy-operator/v0.16.3/getting-started/installation/olm/).

Before configuring the operator with the `OperatorGroup` and the `Subscription`
resources, some preparations need to be made inside the Kubernetes. This consists
in creating a `Namespace` and inside of it the `ServiceAccount` that will be
used by the operator, a `ClusterRole` and their `ClusterRoleBinding`.

Without this, the operator (which in the end is an application, and so a Pod)
will not be able to make all the operations it is supposed to do.

These resources can be declared as follows, starting with the `Namespace` and
`ServiceAccount`:

```bash
cat << EOF | kubectl apply -f -
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: trivy-system
---
# ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: trivy-operator
  namespace: trivy-system
EOF
```

And then the `ClusterRole` with the `ClusterRoleBinding`:

```bash
cat << EOF | kubectl apply -f -
# ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: trivy-operator
rules:
- verbs:
    - get
    - list
    - watch
  apiGroups:
    - ""
  resources:
    - pods
    - pods/log
    - replicationcontrollers
    - services
    - resourcequotas
    - limitranges
- verbs:
    - get
    - list
    - watch
  apiGroups:
    - ""
  resources:
    - nodes
- verbs:
    - list
    - watch
    - get
    - create
    - update
  apiGroups:
    - ""
  resources:
    - configmaps
    - secrets
    - serviceaccounts
- verbs:
    - delete
  apiGroups:
    - ""
  resources:
    - secrets
- verbs:
    - create
  apiGroups:
    - ""
  resources:
    - events
- verbs:
    - get
    - list
    - watch
  apiGroups:
    - apps
  resources:
    - replicasets
    - statefulsets
    - daemonsets
    - deployments
- verbs:
    - get
    - list
    - watch
  apiGroups:
    - policy
  resources:
    - podsecuritypolicies
- verbs:
    - get
    - list
    - watch
    - create
    - update
    - delete
  apiGroups:
    - aquasecurity.github.io
  resources:
    - vulnerabilityreports
    - configauditreports
    - clustercompliancereports
    - clusterconfigauditreports
    - exposedsecretreports
    - sbomreports
    - rbacassessmentreports
    - infraassessmentreports
    - clusterrbacassessmentreports
    - clusterinfraassessmentreports
- verbs:
    - create
    - get
    - update
  apiGroups:
    - coordination.k8s.io
  resources:
    - leases
---
# ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: trivy-operator
  labels:
    app.kubernetes.io/name: trivy-operator
    app.kubernetes.io/instance: trivy-operator
    app.kubernetes.io/version: "0.1.4"
    app.kubernetes.io/managed-by: kubectl
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: trivy-operator
subjects:
  - kind: ServiceAccount
    name: trivy-operator
    namespace: trivy-system
EOF
```

With all this in place, it will be possible to make the Trivy operator to be
managed by OLM.

## Install an operator using OLM

We will now use OLM to install the Trivy operator, by creating `OperatorGroup`:

```bash
cat << EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: trivy-operator-group
  namespace: trivy-system
EOF
```

```console
operatorgroup.operators.coreos.com/trivy-operator-group created
```

Install the operator by creating the Subscription:

```bash
cat << EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: trivy-operator-subscription
  namespace: trivy-system
spec:
  channel: alpha
  name: trivy-operator
  source: operatorhubio-catalog
  sourceNamespace: olm
  installPlanApproval: Automatic
  config:
    env:
    - name: OPERATOR_EXCLUDE_NAMESPACES
      value: "kube-system,trivy-system"
EOF
```

```console
subscription.operators.coreos.com/trivy-operator-subscription created
```

The operator will be installed in the `trivy-system` namespace and will select
all namespaces, except `kube-system` and `trivy-system`.

After install, watch the operator come up using the following command:

```bash
kubectl get clusterserviceversions -n trivy-system
```

```console
NAME                     DISPLAY          VERSION   REPLACES                 PHASE
trivy-operator.v0.16.3   Trivy Operator   0.16.3    trivy-operator.v0.16.2   InstallReady
...
trivy-operator.v0.16.3   Trivy Operator   0.16.3    trivy-operator.v0.16.2   Installing
...
trivy-operator.v0.16.3   Trivy Operator   0.16.3    trivy-operator.v0.16.2   Succeeded
```

When the above command succeeds and the `ClusterServiceVersion` has transitioned
from `Installing` to `Succeeded` phase you will also find the operator's
Deployment in the same namespace where the Subscription is:

```bash
kubectl get deployments -n trivy-system
```

```console
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
trivy-operator   1/1     1            1           11m
```

If for some reason it's not ready yet, check the logs of the Deployment for
errors:

```bash
kubectl logs deployment/trivy-operator -n trivy-system
```

## Install Prometheus and MariaDB operators using OLM

A requirement is [Prometheus](https://grafana.com/docs/grafana-cloud/monitor-infrastructure/kubernetes-monitoring/configuration/configure-infrastructure-manually/prometheus/prometheus-operator/)

Prometheus operator installation these two files can be used:

`prometheus-ClusterRole-ClusterRoleBiunding-ServiceAccount.yml`:

```yaml
apiVersion: v1                                                                                                                                   [70/1939]
kind: Namespace
metadata:   
  name: prometheus-system
---     
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:   
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: prometheus-operator
    app.kubernetes.io/version: 0.68.0
  name: prometheus-operator
roleRef:    
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-operator
subjects:
- kind: ServiceAccount
  name: prometheus-operator
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: prometheus-operator
    app.kubernetes.io/version: 0.68.0
  name: prometheus-operator
rules:
- apiGroups:
  - monitoring.coreos.com
  resources:
  - alertmanagers
  - alertmanagers/finalizers
  - alertmanagers/status
  - alertmanagerconfigs
  - prometheuses
  - prometheuses/finalizers
  - prometheuses/status
  - prometheusagents
  - prometheusagents/finalizers
  - prometheusagents/status
  - thanosrulers
  - thanosrulers/finalizers
  - thanosrulers/status
  - scrapeconfigs
  - servicemonitors
  - podmonitors
  - probes
  - prometheusrules
  verbs:
  - '*'
- apiGroups:
  - apps
  resources:                                                                                                                                     [14/1939]
  - statefulsets
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  verbs:
  - '*'
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - list
  - delete
- apiGroups:
  - ""
  resources:
  - services
  - services/finalizers
  - endpoints
  verbs:
  - get
  - create
  - update
  - delete
- apiGroups:
  - ""
  resources:
  - nodes
  verbs:
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - storage.k8s.io
  resources:
  - storageclasses
  verbs:
  - get
---
apiVersion: v1
automountServiceAccountToken: false
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: prometheus-operator
    app.kubernetes.io/version: 0.68.0
  name: prometheus-operator
  namespace: default
```

And `prometheus-operator-OperatorGroup-Subscription.yaml`:

```yaml
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: prometheus-operator-group
  namespace: prometheus-system
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: prometheus-operator-subscription
  namespace: prometheus-system
spec:
  channel: beta
  name: prometheus
  source: operatorhubio-catalog
  sourceNamespace: olm
  installPlanApproval: Automatic
```

Then these two files can be used:

`mariadb-operator-ServiceAccount-Role-RoleBinding.yaml`:

```yaml
---
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  name: mariadb-system
---
# ServiceAccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mariadb-operator
  namespace: mariadb-system
---
# ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: mariadb-operator
  labels:
    app.kubernetes.io/name: mariadb-operator
subjects:
  - kind: ServiceAccount
    name: mariadb-operator
    namespace: mariadb-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

and `mariadb-operator-OperatorGroup-Subscription.yaml`

```yaml
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: mariadb-operator-group
  namespace: mariadb-system
spec:
  targetNamespaces:
  - mariadb-system
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: mariadb-operator-subscription
  namespace: mariadb-system
spec:
  channel: alpha
  name: mariadb-operator
  source: operatorhubio-catalog
  sourceNamespace: olm
  installPlanApproval: Automatic
```

So:

```console
$ kubectl create -f mariadb-operator-ServiceAccount-Role-RoleBinding.yaml
$ kubectl create -f mariadb-operator-OperatorGroup-Subscription.yaml
```

And after some time:

```console
$ kubectl -n mariadb-system get all
NAME                                                            READY   STATUS    RESTARTS   AGE
pod/mariadb-operator-helm-controller-manager-75d96bf567-w5qrs   1/1     Running   0          3m46s

NAME                                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mariadb-operator-helm-controller-manager   1/1     1            1           3m47s

NAME                                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/mariadb-operator-helm-controller-manager-75d96bf567   1         1         1       3m46
```

Make some tests:

```console
$ git clone https://github.com/mariadb-operator/mariadb-operator
Cloning into 'mariadb-operator'...
remote: Enumerating objects: 6436, done.
remote: Counting objects: 100% (6436/6436), done.
remote: Compressing objects: 100% (1878/1878), done.
remote: Total 6436 (delta 4281), reused 5895 (delta 4056), pack-reused 0
Receiving objects: 100% (6436/6436), 1.67 MiB | 21.66 MiB/s, done.
Resolving deltas: 100% (4281/4281), done.

(ansible-venv) [kirater@training-kfs-minikube operators]$ kubectl apply -f mariadb-operator/examples/manifests/config
persistentvolumeclaim/mariabackup created
configmap/mariadb created
configmap/mariadb-my-cnf created
secret/mariadb created
secret/user created

$ kubectl apply -f mariadb-operator/examples/manifests/mariadb_v1alpha1_mariadb.yaml
mariadb.mariadb.mmontes.io/mariadb created

$ kubectl get mariadbs
NAME      READY   STATUS   PRIMARY POD   AGE
mariadb                                  36s
```

With MetalLB should be possible to allocate IPs and have a completed output
check [Quickstart](https://github.com/mariadb-operator/mariadb-operator/blob/main/README.md#quickstart).
```
