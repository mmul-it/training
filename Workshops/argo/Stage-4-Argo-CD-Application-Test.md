# Argo CD Workshop - Stage 4

To simulate an Argo CD managed workload a local Git repository containing a
Kubernetes deployment will be created.

This repository will be accessible by each Kubernetes Kind cluster via SSH, and
in practice it will be a local directory.

On the Argo CD side a simple application will be initially deployed, followed by
what is called an **Application Set**.

## Create and enable the Git repository

To prepare the local repository a SSH key pair will be generated, and enabled:

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
```

To manage the local repository `git` must be installed and the local directory
created and populated with an `application.yml` file containing a deployment:

```console
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

The yaml will produce:

- A `ConfigMap` that defines an `index.php` file that prints some env variables.
- A `Deployment` named `webserver` with an Apache webserver with PHP that will
expose the `index.php` file.
- A `Service` with type `LoadBalancer` that will expose the `80` port of the
deployment.

## Configure the Git repository in Argo CD

To make Argo CD able to access the SSH Git repository, the SSH key and
repository must be enabled in Argo CD:

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

To check that everything is working as expected, a first application will be
created:

```console
$ argocd app create webserver-prod --repo kirater@172.18.0.1:/home/kirater/kirater-repo --dest-server https://172.18.0.1:8443 --path . --sync-policy auto
application 'webserver-prod' created

$ argocd app list
NAME                   CLUSTER                  NAMESPACE  PROJECT  STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                           PATH  TARGET
argocd/webserver-prod  https://172.18.0.1:8443             default  Synced  Healthy  Auto        <none>      kirater@172.18.0.1:/home/kirater/kirater-repo  .
```

Note that in the Argo CD cluster list the `kind-prod` cluster status is now
`Successful`:

```console
$ argocd cluster list 
SERVER                          NAME        VERSION  STATUS      MESSAGE                                                  PROJECT
https://172.18.0.1:8443         kind-prod   1.29     Successful                                                           
https://172.18.0.1:7443         kind-test            Unknown     Cluster has no applications and is not being monitored.  
https://kubernetes.default.svc  in-cluster           Unknown     Cluster has no applications and is not being monitored.
```

Since the `--sync-policy auto` option was used in the command line, the auto
synchronization will automatically produce the resources contained inside the
yaml file previously defined inside the Git repository:

```console
$ kubectl --context kind-prod --namespace kiraterns get all
NAME                             READY   STATUS    RESTARTS   AGE
pod/webserver-5d45bdd47f-t62p9   1/1     Running   0          4m10s

NAME                TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
service/webserver   LoadBalancer   10.96.213.199   172.18.0.140   80:30963/TCP   4m10s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/webserver   1/1     1            1           4m10s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/webserver-5d45bdd47f   1         1         1       4m10s
```

And the application will be available on the `172.18.0.140` IP:

```console
$ lynx 172.18.0.140 -dump
   Application info:
   THIS WILL ONLY BE PRESENT IN THE TEST BRANCH
   Node name: prod-control-plane
   Node IP: 172.18.0.4
   Pod namespace: kiraterns
   Pod name: webserver-5d45bdd47f-t62p9
   Pod IP: 10.244.0.15
```

The `lynx` tool is used instead of `curl` just for better rendering.

To proceed with a more complex scenario this application can be now removed:

```console
$ argocd app delete argocd/webserver-prod
Are you sure you want to delete 'argocd/webserver-prod' and all its resources? [y/n] y
application 'argocd/webserver-prod' deleted
```

Note that this will fully remove the resources from the destination cluster.

## Create an Application Set in Argo CD

An **Application Set** in Argo CD is a collection of applications that share
similar configuration but may differ based on parameters like environment or
the Git repository branch.

It's useful in managing deployments to multiple clusters, such as `kind-test`
and `kind-prod`, by allowing the differentiation of what to deploy based on the
branch of the associated Git repository, enabling streamlined management and
automation of deployments across environments.

[Application Set](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/)
can be detailed with plenty of options. In this example a `branch` field will be
defined for each cluster and will determine from which Git branch the contents
of the repository will be taken.

Variables in Application Set are expressed between `{{` and `}}` as in `{{cluster}}`,
and in this specific case the `{{branch}}` variable will be used to define the
`targetRevision` of the source, so the branch from where to take the contents of
the repository:

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
```

The app status will reveal a different situation between the `kind-prod` cluster
and the `kind-test` one:

```console
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

This will start the `kind-test` app. It will take at most 180 seconds to get the
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

With everything in place a general verification can be made:

```console
$ kubectl --context kind-prod --namespace kiraterns get services
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
webserver   LoadBalancer   10.96.132.142   172.18.0.140   80:31633/TCP   12m

$ kubectl --context kind-test --namespace kiraterns get services
NAME        TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
webserver   LoadBalancer   10.96.31.57   172.18.0.120   80:31707/TCP   2m8s

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

From now, for every change made on one of the monitored branch `test` or `main`
a change into the destination cluster will be produced within 180 minutes.
