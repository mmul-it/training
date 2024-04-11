# Argo CD Workshop - Stage 3

## Install Argo CD

```console
$ kubectl config use-context kind-argo 
Switched to context "kind-argo".

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

$ curl -sLo argocd https://github.com/argoproj/argo-cd/releases/download/v2.10.6/argocd-linux-amd64
(no output)

$ chmod -v +x argocd 
mode of 'argocd' changed from 0664 (rw-rw-r--) to 0775 (rwxrwxr-x)

$ sudo mv -v argocd /usr/local/bin/
renamed 'argocd' -> '/usr/local/bin/argocd'
```

## Expose Argo CD interface

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

## Configure Argo CD

Get the password:

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

Enable completion:

```console
$ argocd completion bash > .argocd-completion
(no output)

$ echo 'source ~/.argocd-completion' >> .bash_profile
(no ouput)

$ source ~/.argocd-completion
(no output)
```

And then:

```console
$ argocd login --insecure 172.18.0.100
Username: admin
Password: 
'admin:login' logged in successfully
Context '172.18.0.100' updated

$ kubectl config get-contexts -o name
kind-argo
kind-prod
kind-test

$ argocd cluster add kind-test
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `kind-test` with full cluster level privileges. Do you want to continue [y/N]? y
INFO[0001] ServiceAccount "argocd-manager" created in namespace "kube-system" 
INFO[0001] ClusterRole "argocd-manager-role" created    
```
