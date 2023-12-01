# Lab | Use Helm to manage Kubernetes Operators

This lab will use the `helm` tool to install and manage the [MariaDB operator](https://mariadb.org/mariadb-in-kubernetes-with-mariadb-operator/).

## Install Helm

Instructions about how to install `helm` are available [on the official website](https://helm.sh/docs/intro/install/)
and choosing the `v3.13.2` version, the package can be downloaded and put into
the system's path:

```console
$ curl -o helm.tar.gz https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
$ tar -xf helm.tar.gz
$ sudo mv linux-amd64/helm /usr/local/bin/helm
$ helm version
version.BuildInfo{Version:"v3.13.2", GitCommit:"2a2fb3b98829f1e0be6fb18af2f6599e0f4e8243", GitTreeState:"clean", GoVersion:"go1.20.10"}
```

## Install MarDB Operator using Helm

First the mariadb-operator Helm repository should be added to the available ones:

```bash
$ helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
"mariadb-operator" has been added to your repositories
```

Then a specific `namespace` will be created:

```bash
$ kubectl create ns mariadb-system
namespace/mariadb-system created
```

This namespace will run the operator itself. Since there's no need to customize
anything, the operator can be installed like:

```bash
$ helm install mariadb-operator mariadb-operator/mariadb-operator -n mariadb-system
NAME: mariadb-operator
LAST DEPLOYED: Thu Oct 26 12:20:43 2023
NAMESPACE: mariadb-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
mariadb-operator has been successfully deployed! 🦭

Not sure what to do next? 😅 Check out:
https://github.com/mariadb-operator/mariadb-operator#quickstart
```

And from now on the application will be manageable via Helm:

```bash
helm list
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
mariadb-operator        default         1               2023-10-26 12:29:52.351187045 +0000 UTC deployed        mariadb-operator-0.22.0 v0.0.22
```

## Test the operator

### Prepare database storage

The MariaDB custom resource will rely on some persistent storage, and to create
a test one on the nodes, a `storageClass` with a `PersistentVolume` will be
created:

```bash
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local
  annotations:
    storageclass.kubernetes.io/is-default-class: 'true'
provisioner: kubernetes.io/hostpath
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data
  labels:
    type: local
spec:
  storageClassName: local
  persistentVolumeReclaimPolicy: Recycle
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data"
EOF
storageclass.storage.k8s.io/local created
persistentvolume/data created
```

### Prepare the database secret

Every `mariadb` instance needs a root password, that will rely on a secret:

```bash
kubectl create secret generic mariadb --from-literal=root-password=mariadb
secret/mariadb created
```

### Create the resource

Once everything is in place, the `mariadb` can effectively be created:

```bash
kubectl apply -f - <<EOF
apiVersion: mariadb.mmontes.io/v1alpha1
kind: MariaDB
metadata:
  name: mariadb
spec:
  rootPasswordSecretKeyRef:
    name: mariadb
    key: root-password
  image: mariadb:10.11.3
  port: 3306
  volumeClaimTemplate:
    resources:
      requests:
        storage: 100Mi
    accessModes:
      - ReadWriteOnce
  myCnf: |
    [mariadb]
    bind-address=0.0.0.0
    default_storage_engine=InnoDB
    binlog_format=row
    innodb_autoinc_lock_mode=2
    max_allowed_packet=256M
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 300m
      memory: 512Mi
EOF
mariadb.mariadb.mmontes.io/mariadb created
```

Check resource status with `kubectl get all`:

```console
NAME                                            READY   STATUS    RESTARTS   AGE
pod/mariadb-0                                   1/1     Running   0          2m3s
pod/mariadb-operator-54d54bf776-jvqqd           1/1     Running   0          5m9s
pod/mariadb-operator-webhook-7d59c954c4-sqw2r   1/1     Running   0          5m9s

NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kubernetes                 ClusterIP   10.96.0.1       <none>        443/TCP    6m18s
service/mariadb                    ClusterIP   10.97.209.102   <none>        3306/TCP   2m3s
service/mariadb-operator-webhook   ClusterIP   10.106.114.72   <none>        443/TCP    5m9s

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mariadb-operator           1/1     1            1           5m9s
deployment.apps/mariadb-operator-webhook   1/1     1            1           5m9s

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/mariadb-operator-54d54bf776           1         1         1       5m9s
replicaset.apps/mariadb-operator-webhook-7d59c954c4   1         1         1       5m9s

NAME                       READY   AGE
statefulset.apps/mariadb   1/1     2m3s
```

### Access the application

Expose the service with:

```bash
kubectl expose pod mariadb-0  --type LoadBalancer
```

And check the status with `kubectl get service mariadb-0`:

```console
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)          AGE
mariadb-0   LoadBalancer   10.109.27.130   192.168.99.101   3306:32054/TCP   2m35s
```

The service is exposed and accessible, by installing the mariadb package (`yum
-y install mariadb`) and then invoke:

```console
$ mysql -h 192.168.99.101 -u root -pmariadb
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 128
Server version: 10.11.3-MariaDB-1:10.11.3+maria~ubu2204 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0,008 sec)
```
