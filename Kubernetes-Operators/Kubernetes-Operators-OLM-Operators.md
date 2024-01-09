# Lab | Install OLM and manage operators

In this lab you will install the Operator Life-cycle Manager and use it to
manage the deployment of the Trivy Operator life-cycle.

## Install OLM using operator-sdk

The best way to install OLM into a running cluster is by using the operator-sdk`
command:

```console
$ operator-sdk olm install
INFO[0000] Fetching CRDs for version "latest"
INFO[0000] Fetching resources for resolved version "latest"
INFO[0001] Creating CRDs and resources
INFO[0001]   Creating CustomResourceDefinition "catalogsources.operators.coreos.com"
INFO[0001]   CustomResourceDefinition "catalogsources.operators.coreos.com" created
INFO[0001]   Creating CustomResourceDefinition "clusterserviceversions.operators.coreos.com"
INFO[0001]   CustomResourceDefinition "clusterserviceversions.operators.coreos.com" created
INFO[0001]   Creating CustomResourceDefinition "installplans.operators.coreos.com"
INFO[0001]   CustomResourceDefinition "installplans.operators.coreos.com" created
INFO[0001]   Creating CustomResourceDefinition "olmconfigs.operators.coreos.com"
INFO[0001]   CustomResourceDefinition "olmconfigs.operators.coreos.com" created
INFO[0001]   Creating CustomResourceDefinition "operatorconditions.operators.coreos.com"
INFO[0001]   CustomResourceDefinition "operatorconditions.operators.coreos.com" created
INFO[0001]   Creating CustomResourceDefinition "operatorgroups.operators.coreos.com"
INFO[0001]   CustomResourceDefinition "operatorgroups.operators.coreos.com" created
INFO[0001]   Creating CustomResourceDefinition "operators.operators.coreos.com"
INFO[0001]   CustomResourceDefinition "operators.operators.coreos.com" created
INFO[0001]   Creating CustomResourceDefinition "subscriptions.operators.coreos.com"
INFO[0002]   CustomResourceDefinition "subscriptions.operators.coreos.com" created
INFO[0002]   Creating Namespace "olm"
INFO[0002]   Namespace "olm" created
INFO[0002]   Creating Namespace "operators"
INFO[0002]   Namespace "operators" created
INFO[0002]   Creating ServiceAccount "olm/olm-operator-serviceaccount"
INFO[0002]   ServiceAccount "olm/olm-operator-serviceaccount" created
INFO[0002]   Creating ClusterRole "system:controller:operator-lifecycle-manager"
INFO[0002]   ClusterRole "system:controller:operator-lifecycle-manager" created
INFO[0002]   Creating ClusterRoleBinding "olm-operator-binding-olm"
INFO[0002]   ClusterRoleBinding "olm-operator-binding-olm" created
INFO[0002]   Creating OLMConfig "cluster"
INFO[0004]   OLMConfig "cluster" created
INFO[0004]   Creating Deployment "olm/olm-operator"
INFO[0004]   Deployment "olm/olm-operator" created
INFO[0004]   Creating Deployment "olm/catalog-operator"
INFO[0004]   Deployment "olm/catalog-operator" created
INFO[0004]   Creating ClusterRole "aggregate-olm-edit"
INFO[0004]   ClusterRole "aggregate-olm-edit" created
INFO[0004]   Creating ClusterRole "aggregate-olm-view"
INFO[0004]   ClusterRole "aggregate-olm-view" created
INFO[0004]   Creating OperatorGroup "operators/global-operators"
INFO[0004]   OperatorGroup "operators/global-operators" created
INFO[0004]   Creating OperatorGroup "olm/olm-operators"
INFO[0004]   OperatorGroup "olm/olm-operators" created
INFO[0004]   Creating ClusterServiceVersion "olm/packageserver"
INFO[0004]   ClusterServiceVersion "olm/packageserver" created
```

After the command completion the system will be ready to support all the OLM
Custom Resources.

Note that there's also a manual procedure to install OLM, but the number of
action is huge and the overall procedure is error prone.
For more informations, check [Adding OLM to Kubernetes](https://kubebyexample.com/learning-paths/operator-framework/operator-lifecycle-manager/adding-olm-kubernetes).

## Verify OLM Operator Installation

To verify the OLM installation, check the OLM namespace and its pods:

```bash
$ kubectl get namespace olm
NAME   STATUS   AGE
olm    Active   2m57s
```

You should see the OLM-related pods running in the "olm" namespace:

```bash
$ kubectl get pods -n olm
NAME                                READY   STATUS    RESTARTS   AGE
catalog-operator-67dd8d46bc-mgmzk   1/1     Running   0          53s
olm-operator-7b9c8fd79-s29ns        1/1     Running   0          53s
operatorhubio-catalog-khf52         1/1     Running   0          46s
packageserver-6c796b94f5-8qshf      1/1     Running   0          46s
packageserver-6c796b94f5-btftb      1/1     Running   0          46s
```

Check the status of the OLM operator by running:

```bash
$ kubectl get csv -n olm
NAME            DISPLAY          VERSION   REPLACES   PHASE
packageserver   Package Server   0.18.3               Succeeded
```

You should see the OLM operator's CSV in a "Succeeded" state, indicating a
successful installation.

## Install the Trivy Operator using OLM

### Remove any previous installation of the Trivy operator

Since the Trivy operator might have been already installed in the systemd, to
cleanup the system, a manual uninstallation should be performed:

```console
$ export TRIVY_OPERATOR_VERSION=v0.17.1

$ kubectl delete -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/$TRIVY_OPERATOR_VERSION/deploy/static/trivy-operator.yaml
customresourcedefinition.apiextensions.k8s.io "clustercompliancereports.aquasecurity.github.io" deleted
customresourcedefinition.apiextensions.k8s.io "clusterconfigauditreports.aquasecurity.github.io" deleted
customresourcedefinition.apiextensions.k8s.io "clusterinfraassessmentreports.aquasecurity.github.io" deleted
...
```

Lastly the `trivy-system` namespace where the OLM resources will be placed
needs to be created:

```console
$ kubectl create namespace trivy-system
namespace/trivy-system created
```

### Configure OLM resources for the Trivy operator

We will now use OLM to install the Trivy operator, by creating `OperatorGroup`:

```bash
$ cat << EOF | kubectl apply -f -
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: trivy-operator-group
  namespace: trivy-system
EOF
operatorgroup.operators.coreos.com/trivy-operator-group created
```

Install the operator by creating the Subscription:

```bash
$ cat << EOF | kubectl apply -f -
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
subscription.operators.coreos.com/trivy-operator-subscription created
```

The operator will be installed in the `trivy-system` namespace and will select
all namespaces, except `kube-system` and `trivy-system`.

After install, watch the operator come up using the following command:

```bash
$ kubectl get clusterserviceversions -n trivy-system
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
$ kubectl get deployments -n trivy-system
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
trivy-operator   1/1     1            1           11m
```

If for some reason it's not ready yet, check the logs of the Deployment for
errors:

```bash
$ kubectl logs deployment/trivy-operator -n trivy-system
...
```

### Test the Trivy Operator functionalities

The testing environment will be a namespace called `myns`, being sure it is new:

```console
$ kubectl delete namespaces myns
namespace "myns" deleted

$ kubectl create namespace myns
namespace/myns created
```

To begin the test create a deployment with a container affected with knwon
CRITICAL issues, like `nginx:1.18`:

```console
$ kubectl -n myns create deployment nginx --image public.ecr.aws/nginx/nginx:1.18
deployment.apps/nginx created
```

After some time, two additional resources named `configauditreport` and
`vulnerabilityreport` (which will take longer) should have been created:

```console
$ kubectl -n myns get all,vulnerabilityreport,configauditreport
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-7d79b97979-qvjst   1/1     Running   0          3m10s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           3m10s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-7d79b97979   1         1         1       3m10s

NAME                                                                           REPOSITORY    TAG    SCANNER   AGE
vulnerabilityreport.aquasecurity.github.io/replicaset-nginx-7d79b97979-nginx   nginx/nginx   1.18   Trivy     112s

NAME                                                                   SCANNER   AGE
configauditreport.aquasecurity.github.io/replicaset-nginx-7d79b97979   Trivy     3m9s
```

Details about the two reports can be shown using `kubectl describe`.
