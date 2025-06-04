# Lab | Debug a Kubernetes Operator

In this lab you will show how to check status, logs and messages coming from a
Kubernetes Operator.

## Check Operator status

The Operator status is represented by the status of the application, which
corresponds to the status of the deployment:

```console
$ kubectl --namespace metallb-system get all
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/controller-85d8bf7b75-v9tng                            1/1     Running   0          3d
pod/metallb-operator-controller-manager-7c46d89759-jrbdz   1/1     Running   0          3d
pod/metallb-operator-webhook-server-7ccc476797-rjxdk       1/1     Running   0          3d
pod/speaker-c9ssg                                          1/1     Running   0          3d
pod/speaker-ch6dv                                          1/1     Running   0          3d
pod/speaker-jrjjf                                          1/1     Running   0          3d

NAME                                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/metallb-operator-webhook-service   ClusterIP   10.100.3.165    <none>        443/TCP   3d
service/webhook-service                    ClusterIP   10.109.218.40   <none>        443/TCP   3d

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/speaker   3         3         3       3            3           kubernetes.io/os=linux   3d

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller                            1/1     1            1           3d
deployment.apps/metallb-operator-controller-manager   1/1     1            1           3d
deployment.apps/metallb-operator-webhook-server       1/1     1            1           3d

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-85d8bf7b75                            1         1         1       3d
replicaset.apps/metallb-operator-controller-manager-7c46d89759   1         1         1       3d
replicaset.apps/metallb-operator-webhook-server-7ccc476797       1         1         1       3d
```

If one or more Pods are experiencing problems, using `kubectl describe` can help
to identify potential issues.

## Single Pods logs

Each Pod have specific logs, depending on its function.

The operator-controller-manager in this case
`pod/metallb-operator-controller-manager-7c46d89759-jrbdz` covers the
activation of all the dependent resources, listening to Kubernetes engagements:

```console
$ kubectl --namespace metallb-system logs pod/metallb-operator-controller-manager-7c46d89759-jrbdz
...
...
2023-12-01T06:27:46Z    INFO    controllers.MetalLB     updated metallb status successfully     {"metallb": {"name":"metallb","namespace":"metallb-system"}, "condition": "Available", "resource name": "metallb"}
2023-12-01T06:27:46Z    INFO    controllers.MetalLB.syncMetalLBResources        Start
2023/12/01 06:27:46 reconciling (/v1, Kind=ConfigMap) metallb-system/metallb-excludel2
2023/12/01 06:27:46 reconciling (apps/v1, Kind=DaemonSet) metallb-system/speaker
2023/12/01 06:27:46 update was successful
2023/12/01 06:27:46 reconciling (apps/v1, Kind=Deployment) metallb-system/controller
2023/12/01 06:27:46 update was successful
2023-12-01T06:27:46Z    INFO    controllers.MetalLB     updated metallb status successfully     {"metallb": {"name":"metallb","namespace":"metallb-system"}, "condition": "Available", "resource name": "metallb"}
2023-12-01T07:49:31Z    INFO    cert-rotation   no cert refresh needed
2023-12-01T07:49:31Z    INFO    cert-rotation   Ensuring CA cert        {"name": "metallb-operator-webhook-configuration", "gvk": "admissionregistration.k8s.io/v1, Kind=ValidatingWebhookConfiguration", "name": "metallb-operator-webhook-configuration", "gvk": "admissionregistration.k8s.io/v1, Kind=ValidatingWebhookConfiguration"}
2023-12-01T10:21:37Z    INFO    cert-rotation   no cert refresh needed
```

An operator can have more Pods in addition to the operator controller manager,
like in the case of MetalLB, where a controller for the specific instance is
created:

```console
$ kubectl --namespace metallb-system logs pod/controller-85d8bf7b75-v9tng
{"branch":"dev","caller":"main.go:162","commit":"dev","goversion":"gc / go1.20.10 / amd64","level":"info","msg":"MetalLB controller starting (commit dev,
branch dev)","ts":"2023-11-28T10:38:41Z","version":""}
{"caller":"k8s.go:371","level":"info","msg":"secret successfully created","op":"CreateMlSecret","ts":"2023-11-28T10:38:41Z"}
{"caller":"k8s.go:394","level":"info","msg":"Starting Manager","op":"Run","ts":"2023-11-28T10:38:41Z"}
{"level":"info","ts":"2023-11-28T10:38:41Z","msg":"Starting EventSource","controller":"ipaddresspool","controllerGroup":"metallb.io","controllerKind":"IPA
ddressPool","source":"kind source: *v1beta1.IPAddressPool"}
{"level":"info","ts":"2023-11-28T10:38:41Z","msg":"Starting EventSource","controller":"ipaddresspool","controllerGroup":"metallb.io","controllerKind":"IPA
ddressPool","source":"kind source: *v1beta1.AddressPool"}
{"level":"info","ts":"2023-11-28T10:38:41Z","msg":"Starting EventSource","controller":"ipaddresspool","controllerGroup":"metallb.io","controllerKind":"IPA
ddressPool","source":"kind source: *v1beta1.Community"}
{"level":"info","ts":"2023-11-28T10:38:41Z","msg":"Starting EventSource","controller":"ipaddresspool","controllerGroup":"metallb.io","controllerKind":"IPA
ddressPool","source":"kind source: *v1.Namespace"}
{"level":"info","ts":"2023-11-28T10:38:41Z","msg":"Starting Controller","controller":"ipaddresspool","controllerGroup":"metallb.io","controllerKind":"IPAd
dressPool"}
{"level":"info","ts":"2023-11-28T10:38:41Z","msg":"Starting EventSource","controller":"service","controllerGroup":"","controllerKind":"Service","source":"
kind source: *v1.Service"}
{"level":"info","ts":"2023-11-28T10:38:41Z","msg":"Starting EventSource","controller":"service","controllerGroup":"","controllerKind":"Service","source":"
channel source: 0xc00041ae00"}
...
...
```

As well as "speaker" Pods, generally in a number equal to the nodes:

```console
$ kubectl --namespace metallb-system logs pod/speaker-c9ssg  | more
{"branch":"dev","caller":"main.go:100","commit":"dev","goversion":"gc / go1.20.10 / amd64","level":"info","msg":"MetalLB speaker starting (commit dev, bra
nch dev)","ts":"2023-11-28T10:38:48Z","version":""}
{"caller":"announcer.go:125","event":"createARPResponder","interface":"eth0","level":"info","msg":"created ARP responder for interface","ts":"2023-11-28T1
0:38:48Z"}
{"caller":"announcer.go:134","event":"createNDPResponder","interface":"eth0","level":"info","msg":"created NDP responder for interface","ts":"2023-11-28T1
0:38:48Z"}
{"caller":"k8s.go:394","level":"info","msg":"Starting Manager","op":"Run","ts":"2023-11-28T10:38:48Z"}
...
...
```

## Kubernetes events

Kubernetes events are related to specific namespaces, and so there can be no
events for a specific namespace:

```console
$ kubectl --namespace metallb-system get events
No resources found in metallb-system namespace.
```

To watch for *all* the events hte `-A` switch is used:

```console
$ kubectl get events -A
NAMESPACE      LAST SEEN   TYPE      REASON               OBJECT                                           MESSAGE
default        4m19s       Normal    BackOff              pod/kiraop-controller-manager-64b6c998dc-gnlxj   Back-off pulling image "quay.io/mmul/kiraop:0.0.4"
default        4m9s        Warning   ProvisioningFailed   persistentvolumeclaim/mariadb-pv-claim           storageclass.storage.k8s.io "mariadb-sc" not found
olm            55m         Normal    Scheduled            pod/operatorhubio-catalog-tdb5r                  Successfully assigned olm/operatorhubio-catalog-tdb5r to training-kfs-kubernetes-3
olm            55m         Normal    Pulling              pod/operatorhubio-catalog-tdb5r                  Pulling image "quay.io/operatorhubio/catalog:latest"
olm            55m         Normal    Pulled               pod/operatorhubio-catalog-tdb5r                  Successfully pulled image "quay.io/operatorhubio/catalog:latest" in 589ms (589ms including waiting)
olm            55m         Normal    Created              pod/operatorhubio-catalog-tdb5r                  Created container registry-server
olm            55m         Normal    Started              pod/operatorhubio-catalog-tdb5r                  Started container registry-server
olm            55m         Normal    Killing              pod/operatorhubio-catalog-tdb5r                  Stopping container registry-server
trivy-system   55m         Normal    Scheduled            pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Successfully assigned trivy-system/scan-vulnerabilityreport-668c567d4c-ktpnp to training-kfs-kubernetes-3
trivy-system   55m         Normal    Pulled               pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Container image "ghcr.io/aquasecurity/trivy:0.47.0" already present on machine
trivy-system   55m         Normal    Created              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Created container 7c995c1c-4bac-46d2-ae9d-cdcba2f15712
trivy-system   55m         Normal    Started              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Started container 7c995c1c-4bac-46d2-ae9d-cdcba2f15712
trivy-system   55m         Normal    Pulled               pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Container image "ghcr.io/aquasecurity/trivy:0.47.0" already present on machine
trivy-system   55m         Normal    Created              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Created container registry-server
trivy-system   55m         Normal    Started              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Started container registry-server
trivy-system   50m         Normal    Killing              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Stopping container registry-server
trivy-system   55m         Normal    SuccessfulCreate     job/scan-vulnerabilityreport-668c567d4c          Created pod: scan-vulnerabilityreport-668c567d4c-ktpnp
trivy-system   50m         Normal    SuccessfulDelete     job/scan-vulnerabilityreport-668c567d4c          Deleted pod: scan-vulnerabilityreport-668c567d4c-ktpnp
trivy-system   50m         Warning   DeadlineExceeded     job/scan-vulnerabilityreport-668c567d4c          Job was active longer than specified deadline
...
...
```

Since the results can be mixed, using the `--sort-by` option can help creating
chronological overview:

```console
$ kubectl get events -A --sort-by='.metadata.creationTimestamp'
NAMESPACE      LAST SEEN   TYPE      REASON               OBJECT                                           MESSAGE
default        4m38s       Warning   ProvisioningFailed   persistentvolumeclaim/mariadb-pv-claim           storageclass.storage.k8s.io "mariadb-sc" not found
default        4m48s       Normal    BackOff              pod/kiraop-controller-manager-64b6c998dc-gnlxj   Back-off pulling image "quay.io/mmul/kiraop:0.0.4"
trivy-system   55m         Normal    Scheduled            pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Successfully assigned trivy-system/scan-vulnerabilityreport-668c567d4c-ktpnp to training-kfs-kubernetes-3
olm            55m         Normal    Scheduled            pod/operatorhubio-catalog-tdb5r                  Successfully assigned olm/operatorhubio-catalog-tdb5r to training-kfs-kubernetes-3
trivy-system   55m         Normal    SuccessfulCreate     job/scan-vulnerabilityreport-668c567d4c          Created pod: scan-vulnerabilityreport-668c567d4c-ktpnp
olm            55m         Normal    Pulled               pod/operatorhubio-catalog-tdb5r                  Successfully pulled image "quay.io/operatorhubio/catalog:latest" in 589ms (589ms including waiting)
olm            55m         Normal    Started              pod/operatorhubio-catalog-tdb5r                  Started container registry-server
olm            55m         Normal    Pulling              pod/operatorhubio-catalog-tdb5r                  Pulling image "quay.io/operatorhubio/catalog:latest"
olm            55m         Normal    Created              pod/operatorhubio-catalog-tdb5r                  Created container registry-server
trivy-system   55m         Normal    Pulled               pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Container image "ghcr.io/aquasecurity/trivy:0.47.0" already present on machine
trivy-system   55m         Normal    Created              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Created container 7c995c1c-4bac-46d2-ae9d-cdcba2f15712
trivy-system   55m         Normal    Started              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Started container 7c995c1c-4bac-46d2-ae9d-cdcba2f15712
trivy-system   55m         Normal    Pulled               pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Container image "ghcr.io/aquasecurity/trivy:0.47.0" already present on machine
trivy-system   55m         Normal    Created              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Created container registry-server
trivy-system   55m         Normal    Started              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Started container registry-server
olm            55m         Normal    Killing              pod/operatorhubio-catalog-tdb5r                  Stopping container registry-server
trivy-system   50m         Normal    Killing              pod/scan-vulnerabilityreport-668c567d4c-ktpnp    Stopping container registry-server
trivy-system   50m         Normal    SuccessfulDelete     job/scan-vulnerabilityreport-668c567d4c          Deleted pod: scan-vulnerabilityreport-668c567d4c-ktpnp
trivy-system   50m         Warning   DeadlineExceeded     job/scan-vulnerabilityreport-668c567d4c          Job was active longer than specified deadline
...
...
```
