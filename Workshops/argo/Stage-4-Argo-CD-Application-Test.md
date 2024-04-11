# Argo CD Workshop - Stage 4

## Create and enable the Git repository

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

## Configure the Git repository in Argo CD

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

## Enable the application in Argo CD

```console
$ argocd app create webserver-prod --repo kirater@172.18.0.1:/home/kirater/kirater-repo --dest-server https://172.18.0.1:8443 --path . --sync-policy auto
application 'webserver-prod' created
```

## Create an application set in Argo CD

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
