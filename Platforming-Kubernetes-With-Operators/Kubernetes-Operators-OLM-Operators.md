# Lab | Install OLM and manage operators

In this lab you will install the Operator Life-cycle Manager and use it to
manage the deployment of the Trivy Operator life-cycle.

## Install OLM using operator-sdk

The best way to install OLM into a running cluster is by using the operator-sdk`
command:

```console
$ operator-sdk olm install
INFO[0000] Fetching CRDs for version "latest"
...
...
INFO[0029] Successfully installed OLM version "latest"

NAME                                            NAMESPACE    KIND                        STATUS
catalogsources.operators.coreos.com                          CustomResourceDefinition    Installed
clusterserviceversions.operators.coreos.com                  CustomResourceDefinition    Installed
installplans.operators.coreos.com                            CustomResourceDefinition    Installed
olmconfigs.operators.coreos.com                              CustomResourceDefinition    Installed
operatorconditions.operators.coreos.com                      CustomResourceDefinition    Installed
operatorgroups.operators.coreos.com                          CustomResourceDefinition    Installed
operators.operators.coreos.com                               CustomResourceDefinition    Installed
subscriptions.operators.coreos.com                           CustomResourceDefinition    Installed
olm                                                          Namespace                   Installed
operators                                                    Namespace                   Installed
olm-operator-serviceaccount                     olm          ServiceAccount              Installed
system:controller:operator-lifecycle-manager                 ClusterRole                 Installed
olm-operator-binding-olm                                     ClusterRoleBinding          Installed
cluster                                                      OLMConfig                   Installed
olm-operator                                    olm          Deployment                  Installed
catalog-operator                                olm          Deployment                  Installed
aggregate-olm-edit                                           ClusterRole                 Installed
aggregate-olm-view                                           ClusterRole                 Installed
global-operators                                operators    OperatorGroup               Installed
olm-operators                                   olm          OperatorGroup               Installed
packageserver                                   olm          ClusterServiceVersion       Installed
operatorhubio-catalog                           olm          CatalogSource               Installed
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
$ kubectl --namespace olm get pods
NAME                                READY   STATUS    RESTARTS   AGE
catalog-operator-67dd8d46bc-mgmzk   1/1     Running   0          53s
olm-operator-7b9c8fd79-s29ns        1/1     Running   0          53s
operatorhubio-catalog-khf52         1/1     Running   0          46s
packageserver-6c796b94f5-8qshf      1/1     Running   0          46s
packageserver-6c796b94f5-btftb      1/1     Running   0          46s
```

Check the status of the OLM operator by running:

```bash
$ kubectl --namespace olm get csv
NAME            DISPLAY          VERSION   REPLACES   PHASE
packageserver   Package Server   0.18.3               Succeeded
```

You should see the OLM operator's CSV in a "Succeeded" state, indicating a
successful installation.

## Install the Trivy Operator using OLM

### Remove any previous installation of the Trivy operator

Since the Trivy operator might have been already installed in the systemd, to
cleanup the system, this command sequence could be performed:

```console
kubectl --namespace trivy-system delete subscription trivy-operator-subscription
kubectl --namespace trivy-system delete clusterserviceversion trivy-operator.v0.22.0
kubectl --namespace trivy-system delete operatorgroup trivy-operator-group
kubectl delete ns trivy-system
kubectl delete crd vulnerabilityreports.aquasecurity.github.io
kubectl delete crd exposedsecretreports.aquasecurity.github.io
kubectl delete crd configauditreports.aquasecurity.github.io
kubectl delete crd clusterconfigauditreports.aquasecurity.github.io
kubectl delete crd rbacassessmentreports.aquasecurity.github.io
kubectl delete crd infraassessmentreports.aquasecurity.github.io
kubectl delete crd clusterrbacassessmentreports.aquasecurity.github.io
kubectl delete crd clustercompliancereports.aquasecurity.github.io
kubectl delete crd clusterinfraassessmentreports.aquasecurity.github.io
kubectl delete crd clusterconfigauditreports.aquasecurity.github.io
kubectl delete crd sbomreports.aquasecurity.github.io
kubectl delete crd clustersbomreports.aquasecurity.github.io
kubectl delete crd clustervulnerabilityreports.aquasecurity.github.io
```

So, to start again, the `trivy-system` namespace will be created:

```console
$ kubectl create namespace trivy-system
namespace/trivy-system created
```

### Configure OLM resources for the Trivy operator

We will now use OLM to install the Trivy operator, by creating `OperatorGroup`:

```bash
$ cat <<EOF | kubectl apply -f -
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
$ cat <<EOF | kubectl apply -f -
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
  installPlanApproval: Manual
  startingCSV: trivy-operator.v0.17.1
  config:
    env:
    - name: OPERATOR_EXCLUDE_NAMESPACES
      value: "kube-system"
EOF
subscription.operators.coreos.com/trivy-operator-subscription created
```

Since we choose a specific `startingCSV` version with `Manual` as
`installPlanApproval`, the install plan will be in a `pending` status:

```console
$ kubectl --namespace trivy-system get operatorgroup,subscriptions,installplans
NAME                                                      AGE
operatorgroup.operators.coreos.com/trivy-operator-group   19s

NAME                                                            PACKAGE          SOURCE                  CHANNEL
subscription.operators.coreos.com/trivy-operator-subscription   trivy-operator   operatorhubio-catalog   alpha

NAME                                             CSV                      APPROVAL   APPROVED
installplan.operators.coreos.com/install-wtqp9   trivy-operator.v0.17.1   Manual     false
```

To approve the deployment patch the `installplan` resource:

```console
$ kubectl --namespace trivy-system patch installplan install-wtqp9 --type merge -p '{"spec": {"approved":true}}'
installplan.operators.coreos.com/install-wtqp9 patched
```

This will unlock things, creating also the `ClusterServiceVersion` resource:

```console
$ kubectl --namespace trivy-system get operatorgroup,subscriptions,installplans,csv
NAME                                                      AGE
operatorgroup.operators.coreos.com/trivy-operator-group   112s

NAME                                                            PACKAGE          SOURCE                  CHANNEL
subscription.operators.coreos.com/trivy-operator-subscription   trivy-operator   operatorhubio-catalog   alpha

NAME                                             CSV                      APPROVAL   APPROVED
installplan.operators.coreos.com/install-wtqp9   trivy-operator.v0.17.1   Manual     true
installplan.operators.coreos.com/install-ztclm   trivy-operator.v0.18.0   Manual     false

NAME                                                                DISPLAY          VERSION   REPLACES                 PHASE
clusterserviceversion.operators.coreos.com/trivy-operator.v0.17.1   Trivy Operator   0.17.1    trivy-operator.v0.17.0   Succeeded
```

The operator will be installed in the `trivy-system` namespace and will select
all namespaces, except `kube-system`:

```bash
$ kubectl --namespace trivy-system get deployments
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
trivy-operator   1/1     1            1           11m
```

Startup problems can be debugged by looking into the deployment's logs:

```bash
$ kubectl --namespace trivy-system logs deployment/trivy-operator
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
$ kubectl --namespace myns create deployment nginx --image public.ecr.aws/nginx/nginx:1.18
deployment.apps/nginx created
```

After some time, two additional resources named `configauditreport` and
`vulnerabilityreport` (which will take longer) should have been created:

```console
$ kubectl --namespace myns get all,vulnerabilityreport,configauditreport
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
