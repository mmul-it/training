# ArgoCD workshop

## Create 3 Kind instances

Check [this issue](https://github.com/kubernetes-sigs/kind/issues/2744):

```console
$ echo fs.inotify.max_user_watches=655360 | sudo tee -a /etc/sysctl.conf
fs.inotify.max_user_watches=655360

$ echo fs.inotify.max_user_instances=1280 | sudo tee -a /etc/sysctl.conf
fs.inotify.max_user_instances=1280

$ sudo sysctl -p
fs.inotify.max_user_watches = 655360
fs.inotify.max_user_instances = 1280
```

Install:

```console
$ [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64

$ chmod +x ./kind

$ sudo mv ./kind /usr/local/bin/kind

$ cat <<EOF > kind-argo-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 6443
EOF

$ kind create cluster --name argo --config kind-argo-config.yml
Creating cluster "argo" ...
 ✓ Ensuring node image (kindest/node:v1.29.2) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-argo"
You can now use your cluster with:

kubectl cluster-info --context kind-argo

Thanks for using kind! 😊

$ cat <<EOF > kind-test-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 7443
EOF

$ kind create cluster --name test --config kind-test-config.yml
Creating cluster "test" ...
 ✓ Ensuring node image (kindest/node:v1.29.2) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-test"
You can now use your cluster with:

kubectl cluster-info --context kind-test

Have a nice day! 👋

$ cat <<EOF > kind-prod-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 8443
EOF

$ kind create cluster --name prod --config kind-prod-config.yml
Creating cluster "prod" ...
 ✓ Ensuring node image (kindest/node:v1.29.2) 🖼
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-prod"
You can now use your cluster with:

kubectl cluster-info --context kind-prod

Thanks for using kind! 😊
```

Install `kubectl`:

```console
$ sudo yum -y install bash-completion
...

$ source /etc/profile.d/bash_completion.sh
(no output)

$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
...

$ chmod -v +x kubectl && sudo mv kubectl /usr/local/bin
mode of 'kubectl' changed from 0664 (rw-rw-r--) to 0775 (rwxrwxr-x)

$ kubectl completion bash > ~/.kubectl-completion
(no output)

$ echo "source ~/.kubectl-completion" >> ~/.bash_profile
(no output)

$ source ~/.kubectl-completion
(no output)
```

## Configure MetalLB to expose ArgoCD server

### Step 1 - Enable metallb in Kind

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

### Step 2 - Install ArgoCD

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

### Step 5 - Expose ArgoCD interface

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

### Configure ArgoCD

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

```
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
```

Prepare the local repo:

```console
$ ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/kirater/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/kirater/.ssh/id_rsa
Your public key has been saved in /home/kirater/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:mp5G1SOtCOnP1sJKI5Z5HAq6EQ2h5WeRaeeVRDESXUc kirater@training-adm
The key's randomart image is:
+---[RSA 3072]----+
|. . .oo==+..E    |
|.+  +...+. .     |
|o ..o+ . o       |
| o oo . o +      |
|o .... oSo .     |
|.o =..oo.        |
|o * ==o.         |
| + + oB..        |
|.   .+o.         |
+----[SHA256]-----+

$ cat .ssh/id_rsa.pub >> .ssh/authorized_keys
(no output)

$ ssh kirater@172.18.0.1 uptime
 12:15:23 up  1:24,  1 user,  load average: 0.65, 1.06, 1.08

$ sudo yum -y install git
...

$ mkdir -v kirater-repo && cd kirater-repo
mkdir: created directory 'kirater-repo'

$ git init --initial-branch=main
Initialized empty Git repository in /home/kirater/kirater-repo/.git/

$ git config user.name Kirater
(no output)

$ git config user.email kirater@kiratech.it
(no output)

$ cat <<EOF > application.yml
apiVersion: v1
kind: Namespace
metadata:
  name: kiraterns
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: index-php
  namespace: kiraterns
data:
  index.php: |
    Application info:<br />
    Node name: <b><?=getenv('NODE_NAME', true);?></b><br />
    Node IP: <b><?=getenv('NODE_IP', true);?></b><br />
    Pod namespace: <b><?=getenv('POD_NAMESPACE', true);?></b><br />
    Pod name: <b><?=getenv('POD_NAME', true);?></b><br />
    Pod IP: <b><?=getenv('POD_IP', true);?></b><br />
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver
spec:
  replicas: 1
  selector:
    matchLabels:
        app: webserver
  template:
    metadata:
      labels:
        app: webserver
    spec:
      containers:
        - name: webserver
          image: php:apache
          env:
          - name: NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          - name: NODE_IP
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_IP
            valueFrom:
              fieldRef:
                fieldPath: status.podIP
          volumeMounts:
          - name: docroot
            mountPath: /var/www/html
      volumes:
        - name: docroot
          configMap:
            name: index-php
---
apiVersion: v1
kind: Service
metadata:
  name: webserver
  namespace: kiraterns
spec:
  type: LoadBalancer
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: webserver
EOF

$ git add .
(no output)

$ git commit -m "Initial commit"
[main (root-commit) 35f7dac] Initial commit
 1 file changed, 78 insertions(+)
 create mode 100644 application.yml

$ cd ..
(no output)
```

Enable SSH key and repository in argocd:

```console
$ cat <<EOF > ssh-repo-secret.yml
apiVersion: v1
kind: Secret
metadata:
  name: kirater-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-cred
stringData:
  type: git
  url: kirater@172.18.0.1:/home/kirater/kirater-repo
  sshPrivateKey: |
$(cat ~/.ssh/id_rsa | sed 's/^/    /g')
EOF

$ kubectl apply -f ssh-repo-secret.yml 
secret/kirater-repo configured

$ argocd repo add kirater@172.18.0.1:/home/kirater/kirater-repo --name kirater-repo --insecure-skip-server-verification 
Repository 'kirater@172.18.0.1:/home/kirater/kirater-repo' added
```

Enable the app:

```console
$ argocd app create webserver-prod --repo kirater@172.18.0.1:/home/kirater/kirater-repo --dest-server https://172.18.0.1:8443 --path . --sync-policy auto
application 'webserver-prod' created
```

Create an app set:

```console
$ cat <<EOF > argo-appset.yml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: webserver
spec:
  generators:
  - list:
      elements:
      - cluster: test
        url: https://172.18.0.1:7443
        branch: test
      - cluster: prod
        url: https://172.18.0.1:8443
        branch: main
  template:
    metadata:
      name: '{{cluster}}-webserver'
    spec:
      project: default
      source:
        repoURL: kirater@172.18.0.1:/home/kirater/kirater-repo
        targetRevision: '{{branch}}'
        path: .
      destination:
        server: '{{url}}'
      syncPolicy:
        automated: {}
EOF

$ argocd appset create argo-appset.yml 
ApplicationSet 'webserver' created

$ argocd app list 
NAME                   CLUSTER                  NAMESPACE  PROJECT  STATUS   HEALTH   SYNCPOLICY  CONDITIONS       REPO                                           PATH  TARGET
argocd/prod-webserver  https://172.18.0.1:8443             default  Synced   Healthy  Auto        <none>           kirater@172.18.0.1:/home/kirater/kirater-repo  .     main
argocd/test-webserver  https://172.18.0.1:7443             default  Unknown  Healthy  Auto        ComparisonError  kirater@172.18.0.1:/home/kirater/kirater-repo  .     test
```

The production (targeting `main` branch) is `Synced` but to make also the
second one `Synced` the `test` branch should be created as well, i.e. by
simulating a change:

```console
$ vim application.yml
(vim interface opens in which the index.php ConfigMap could be changed)

$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   application.yml

no changes added to commit (use "git add" and/or "git commit -a")

$ git add .
(no output)

$ git checkout -b test
Switched to a new branch 'test'

$ git commit -m "Simulate test only modification"
[test 5a886ae] Simulate test only modification
 1 file changed, 1 insertion(+)
```

And so start monitoring the apps. It will take at most 180 seconds to get the
fully synced status:

```console
$ argocd app list
NAME                   CLUSTER                  NAMESPACE  PROJECT  STATUS   HEALTH   SYNCPOLICY  CONDITIONS       REPO                                           PATH  TARGET
argocd/prod-webserver  https://172.18.0.1:8443             default  Synced   Healthy  Auto        <none>           kirater@172.18.0.1:/home/kirater/kirater-repo  .     main
argocd/test-webserver  https://172.18.0.1:7443             default  Unknown  Healthy  Auto        ComparisonError  kirater@172.18.0.1:/home/kirater/kirater-repo  .     test

$ argocd app list
NAME                   CLUSTER                  NAMESPACE  PROJECT  STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                           PATH  TARGET
argocd/prod-webserver  https://172.18.0.1:8443             default  Synced  Healthy  Auto        <none>      kirater@172.18.0.1:/home/kirater/kirater-repo  .     main
argocd/test-webserver  https://172.18.0.1:7443             default  Synced  Healthy  Auto        <none>      kirater@172.18.0.1:/home/kirater/kirater-repo  .     test
```

To verify everything:

```console
$ kubectl get services -n kiraterns --context kind-prod 
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
webserver   LoadBalancer   10.96.132.142   172.18.0.140   80:31633/TCP   12m

$ kubectl get services -n kiraterns --context kind-test
NAME        TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
webserver   LoadBalancer   10.96.31.57   172.18.0.120   80:31707/TCP   2m8s

$ sudo yum -y install lynx
...

$ lynx 172.18.0.140 -dump
   Application info:
   Node name: prod-control-plane
   Node IP: 172.18.0.4
   Pod namespace: kiraterns
   Pod name: webserver-5d45bdd47f-jljqh
   Pod IP: 10.244.0.14

$ lynx 172.18.0.120 -dump
   Application info:
   THIS WILL ONLY BE PRESENT IN THE TEST BRANCH
   Node name: test-control-plane
   Node IP: 172.18.0.3
   Pod namespace: kiraterns
   Pod name: webserver-5d45bdd47f-7j9dj
   Pod IP: 10.244.0.10
```
