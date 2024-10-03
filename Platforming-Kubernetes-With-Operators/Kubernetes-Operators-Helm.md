# Lab | Use Helm to manage Kubernetes Operators

In this lab you will use the `helm` tool to install and manage the [MariaDB operator](https://mariadb.org/mariadb-in-kubernetes-with-mariadb-operator/).

## Install Helm

Instructions about how to install `helm` are available [on the official website](https://helm.sh/docs/intro/install/)
and choosing the `v3.13.2` version, the package can be downloaded and put into
the system's path:

```console
$ curl -o helm.tar.gz https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
...

$ tar -xvf helm.tar.gz
linux-amd64/
linux-amd64/helm
linux-amd64/LICENSE
linux-amd64/README.md

$ sudo mv -v linux-amd64/helm /usr/local/bin/helm
renamed 'linux-amd64/helm' -> '/usr/local/bin/helm'

$ helm version
version.BuildInfo{Version:"v3.13.2", GitCommit:"2a2fb3b98829f1e0be6fb18af2f6599e0f4e8243", GitTreeState:"clean", GoVersion:"go1.20.10"}
```

## Install MariaDB Operator using Helm

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
anything, the `0.32.0` version of the operator can be installed as follows:

```bash
$ helm -n mariadb-system install mariadb-operator mariadb-operator/mariadb-operator --version 0.32.0
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
$ helm -n mariadb-system list
NAME              NAMESPACE       REVISION  UPDATED                                   STATUS    CHART                    APP VERSION
mariadb-operator  mariadb-system  1         2024-10-03 11:54:01.457240836 +0200 CEST  deployed  mariadb-operator-0.32.0  v0.0.32
```

## Test the operator

### Prepare the database namespace and secret

Every `mariadb` instance needs a root password, that will rely on a secret that
will be created inside a specific namespace:

```bash
$ kubectl create namespace mariadb-test
namespace/mariadb-test created

$ kubectl -n mariadb-test create secret generic mariadb --from-literal=root-password=mariadb
secret/mariadb created
```

### Create the resource

Once everything is in place, the `mariadb` can effectively be created:

```bash
$ cat <<EOF | kubectl apply -f -
apiVersion: k8s.mariadb.com/v1alpha1
kind: MariaDB
metadata:
  name: mariadb
  namespace: mariadb-test
spec:
  rootPasswordSecretKeyRef:
    name: mariadb
    key: root-password
  image: mariadb:10.11.3
  port: 3306
  storage:
    ephemeral: true
EOF
mariadb.mariadb.mmontes.io/mariadb created
```

Check resource status:

```console
$ kubectl -n mariadb-test get all
NAME            READY   STATUS    RESTARTS   AGE
pod/mariadb-0   1/1     Running   0          93s

NAME                       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/mariadb            ClusterIP   10.104.37.78   <none>        3306/TCP   94s
service/mariadb-internal   ClusterIP   None           <none>        3306/TCP   94s

NAME                       READY   AGE
statefulset.apps/mariadb   1/1     94s
```

### Access the application

Expose the service with:

```bash
$ kubectl -n mariadb-test expose pod mariadb-0 --type LoadBalancer
service/mariadb-0 exposed
```

And check the status with `kubectl get service mariadb-0`:

```console
$ kubectl -n mariadb-test get service mariadb-0
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)          AGE
mariadb-0   LoadBalancer   10.96.129.190   192.168.99.222   3306:32128/TCP   28s
```

The service is exposed and accessible, by installing the mariadb package (`sudo
yum -y install mariadb` for Red Hat based systems and `sudo apt install -y
mariadb` for Debian based systems) and then invoke:

```console
$ mysql -h 192.168.99.222 -u root -pmariadb
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
