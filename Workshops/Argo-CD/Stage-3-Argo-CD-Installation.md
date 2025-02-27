# Argo CD Workshop - Stage 3

Now that each cluster is able to expose reachable IPs, it is time to install
the [Argo CD](https://argo-cd.readthedocs.io/) environment on the
`kind-ctlplane` Kubernetes cluster.

## Install Argo CD

Argo CD needs a dedicated namespace and can be installed by its yaml file, the
same way as MetalLB:

```console
$ kubectl config use-context kind-ctlplane
Switched to context "kind-ctlplane".

$ kubectl create namespace argocd
namespace/argocd created

$ kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
customresourcedefinition.apiextensions.k8s.io/applications.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/applicationsets.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/appprojects.argoproj.io created
...
service/argocd-server created
...
networkpolicy.networking.k8s.io/argocd-server-network-policy created
```

## Install Argo CD client tool

Interacting with Argo CD is possible by web interface or by using the command
line tool named `argocd`, that can be installed the same way as `kubectl`:

```console
$ curl -sLo argocd https://github.com/argoproj/argo-cd/releases/download/v2.10.6/argocd-linux-amd64
(no output)

$ chmod -v +x argocd
mode of 'argocd' changed from 0664 (rw-rw-r--) to 0775 (rwxrwxr-x)

$ sudo mv -v argocd /usr/local/bin/
renamed 'argocd' -> '/usr/local/bin/argocd'
```

As well as `kubectl`, also `argocd` supports bash completion:

```console
$ argocd completion bash > .argocd-completion
(no output)

$ echo 'source ~/.argocd-completion' >> .bash_profile
(no ouput)

$ source ~/.argocd-completion
(no output)
```

## Expose Argo CD interface

To start interacting with Argo CD its interface must be available, and by
default the `argocd-server` service is a `ClusterIP`, so not reachable outside
the Kubernetes cluster:

```console
$ kubectl -n argocd get services
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP   10.96.179.141   <none>        7000/TCP,8080/TCP            32s
argocd-dex-server                         ClusterIP   10.96.175.12    <none>        5556/TCP,5557/TCP,5558/TCP   32s
argocd-metrics                            ClusterIP   10.96.143.93    <none>        8082/TCP                     32s
argocd-notifications-controller-metrics   ClusterIP   10.96.19.163    <none>        9001/TCP                     32s
argocd-redis                              ClusterIP   10.96.67.50     <none>        6379/TCP                     32s
argocd-repo-server                        ClusterIP   10.96.26.76     <none>        8081/TCP,8084/TCP            32s
argocd-server                             ClusterIP   10.96.81.123    <none>        80/TCP,443/TCP               32s
argocd-server-metrics                     ClusterIP   10.96.136.57    <none>        8083/TCP                     32s
```

Exposing it, it's just a matter of patching the service to make it a
`LoadBalancer`:

```console
$ kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
service/argocd-server patched

$ kubectl -n argocd get service
NAME                                      TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP      10.96.238.31     <none>          7000/TCP,8080/TCP            82m
argocd-dex-server                         ClusterIP      10.106.242.93    <none>          5556/TCP,5557/TCP,5558/TCP   82m
argocd-metrics                            ClusterIP      10.105.247.255   <none>          8082/TCP                     82m
argocd-notifications-controller-metrics   ClusterIP      10.108.202.75    <none>          9001/TCP                     82m
argocd-redis                              ClusterIP      10.99.212.167    <none>          6379/TCP                     82m
argocd-repo-server                        ClusterIP      10.102.40.247    <none>          8081/TCP,8084/TCP            82m
argocd-server                             LoadBalancer   10.98.135.113    172.18.0.100    80:31850/TCP,443:32504/TCP   82m
argocd-server-metrics                     ClusterIP      10.104.249.156   <none>          8083/TCP                     82m
```

MetalLB assigned the first available IP, `172.18.0.100`, but a specific IP part
of the range can be requested.

## Configure Argo CD

Argo CD interface should now be reachable. First thing to do will be to get the
password for the default `admin` user, with:

```console
$ kubectl -n argocd get secrets argocd-initial-admin-secret  --template={{.data.password}} | base64 -d
thvQXxV-FujhyztN
```

Or:

```console
$ argocd admin initial-password -n argocd
thvQXxV-FujhyztN

 This password must be only used for first time login. We strongly recommend you update the password using `argocd account update-password`.
```

Then, with `argocd login` the connection with the service will be available:

```console
$ argocd login --insecure 172.18.0.100
Username: admin
Password:
'admin:login' logged in successfully
Context '172.18.0.100' updated
```

To complete the initial Argo CD configuration, the `kind-test` and `kind-prod`
clusters should be added to the ones available inside Argo CD.

The `argocd` client tool relies on what's inside the local Kubernetes
configuration. In this case the contexts for the installed clusters are:

```console
$ kubectl config get-contexts -o name
kind-ctlplane
kind-prod
kind-test
```

By using `argocd cluster add` for each context, the clusters will become
available:

```console
$ argocd cluster add kind-test
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `kind-test` with full cluster level privileges. Do you want to continue [y/N]? y
INFO[0001] ServiceAccount "argocd-manager" created in namespace "kube-system"
INFO[0001] ClusterRole "argocd-manager-role" created
INFO[0001] ClusterRoleBinding "argocd-manager-role-binding" created
INFO[0006] Created bearer token secret for ServiceAccount "argocd-manager"
Cluster 'https://172.18.0.1:7443' added

$ argocd cluster add kind-prod
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `kind-prod` with full cluster level privileges. Do you want to continue [y/N]? y
INFO[0001] ServiceAccount "argocd-manager" created in namespace "kube-system"
INFO[0001] ClusterRole "argocd-manager-role" created
INFO[0001] ClusterRoleBinding "argocd-manager-role-binding" created
INFO[0006] Created bearer token secret for ServiceAccount "argocd-manager"
Cluster 'https://172.18.0.1:8443' added

$ argocd cluster list
SERVER                          NAME        VERSION  STATUS      MESSAGE                                                  PROJECT
https://172.18.0.1:8443         kind-prod            Unknown     Cluster has no applications and is not being monitored.
https://172.18.0.1:7443         kind-test            Unknown     Cluster has no applications and is not being monitored.
https://kubernetes.default.svc  in-cluster           Unknown     Cluster has no applications and is not being monitored.
```

To start deploying applications it is possible to proceed with [Stage 4](Stage-4-Argo-CD-Application-Test.md).
