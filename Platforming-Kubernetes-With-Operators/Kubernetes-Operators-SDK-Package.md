# Lab | Manage Ansible Operator packages

In this lab you will define a method to package and version the Ansible based
Kubernetes Operator.

## Make the original working directory a Git repository

The first thing we need is to "convert" the actual working directory into a git
repository. This can be done by using `git init`:

```console
$ cd kiraop && git init --initial-branch=main
Initialized empty Git repository in /home/kirater/operators/kiraop/.git/

$ git config --global user.email "kirater@kiratech.it"
(no output)

$ git config --global user.name "Kirater"
(no output)

$ git add . && git commit -m "Initial commit"
[main (root-commit) 535c41c] Initial commit
 71 files changed, 2064 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 Dockerfile
 create mode 100644 Makefile
 create mode 100644 PROJECT
 ...
 ...
```

## Generate the first bundle

It is time to generate the first bundle for version `0.0.1`, this command is
based on the previous settings applied to the `Makefile` that were made in
[Kubernetes-Operators-SDK-Create.md](Kubernetes-Operators-SDK-Create.md):

```console
$ IMG=quay.io/mmul/kiraop:v0.0.1 make bundle
/usr/local/bin/operator-sdk generate kustomize manifests -q

Display name for the operator (required):
> Kiraop

Description for the operator (required):
> Kiratech Operators Training Operator

Provider's name for the operator (required):
> Kiratech S.p.A.

Any relevant URL for the provider name (optional):
> https://www.kiratech.it

Comma-separated list of keywords for your operator (required):
> sample,training

Comma-separated list of maintainers and their emails (e.g. 'name1:email1, name2:email2') (required):
> kirater:kirater@kiratech.it

cd config/manager && /home/kirater/operators/kiraop/bin/kustomize edit set image controller=quay.io/mmul/kiraop:v0.0.1
/home/kirater/operators/kiraop/bin/kustomize build config/manifests | /usr/local/bin/operator-sdk generate bundle -q --overwrite --version 0.0.1
INFO[0000] Creating bundle.Dockerfile
INFO[0000] Creating bundle/metadata/annotations.yaml
INFO[0000] Bundle metadata generated successfully
/usr/local/bin/operator-sdk bundle validate ./bundle
INFO[0000] All validation tests have completed successfully
```

## Getting a specific version

The previous operation generated new files:

```console
$ git status
On branch main
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        bundle.Dockerfile
        bundle/
        config/manifests/bases/

no changes added to commit (use "git add" and/or "git commit -a")
```

To keep track of everything inside the repo, a new git commit should be created,
but before this we will add the single file that will represent the entire
version, created by using the `kustomize` to generate a specific file:

```console
$ bin/kustomize build config/manifests --output v0.0.1.yaml
(no output)
```

The `v0.0.1.yaml` file will contain the entire operator's declaration, it will
be the "package" of what have been developed.

Now everything can be committed:

```console
$ git add . && git commit -m "Version v0.0.1"
[main a194071] Version v0.0.1
 10 files changed, 1005 insertions(+), 1 deletion(-)
 create mode 100644 bundle.Dockerfile
 create mode 100644 bundle/manifests/kiraop-controller-manager-metrics-service_v1_service.yaml
 create mode 100644 bundle/manifests/kiraop-metrics-reader_rbac.authorization.k8s.io_v1_clusterrole.yaml
 create mode 100644 bundle/manifests/kiraop.clusterserviceversion.yaml
 create mode 100644 bundle/manifests/kiratech.it_akits.yaml
 create mode 100644 bundle/metadata/annotations.yaml
 create mode 100644 bundle/tests/scorecard/config.yaml
 create mode 100644 config/manifests/bases/kiraop.clusterserviceversion.yaml
 create mode 100644 v0.0.1.yaml
```

## Generate a new version

To simulate a new version generation, let's change something in our operator, by
adding a custom welcome page to the webserver it deploys.

Change `roles/akit/tasks/main.yml` by adding:

```yaml
- name: Create Akit ConfigMap.
  kubernetes.core.k8s:
    state: present
    resource_definition:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: index-html
        namespace: "{{ akit_namespace }}"
      data:
        index.html: |
          This is my faboulous Webserver inside {{ akit_namespace }}!
```

And change the deployment to mount the configmap:

```yaml
- name: Create Akit Deployment.
  kubernetes.core.k8s:
    state: present
    resource_definition:
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: akit
        namespace: "{{ akit_namespace }}"
        labels:
          app: akit
      spec:
        replicas: 1
        selector:
          matchLabels:
            app: akit
        template:
          metadata:
            labels:
              app: akit
          spec:
            containers:
              - name: akit
                image: "{{ akit_container }}"
                volumeMounts:
                - name: docroot
                  mountPath: /usr/share/nginx/html
            volumes:
              - name: docroot
                configMap:
                  name: index-html
```

Then commit, and repeat the same steps above, to generate `v0.0.2`.

```console
$ IMG=quay.io/mmul/kiraop:v0.0.2 make docker-build docker-push
docker build -t quay.io/mmul/kiraop:v0.0.2 .
[+] Building 0.8s (11/11) FINISHED
...
v0.0.2: digest: sha256:3668ebcf8052b31ea4dd1d6aaa8130168a0b0b1fd791ee4de6665baf96b104ec size: 3452

$ IMG=quay.io/mmul/kiraop:v0.0.2 make bundle
/usr/local/bin/operator-sdk generate kustomize manifests -q
cd config/manager && /home/kirater/operators/kiraop/bin/kustomize edit set image controller=quay.io/mmul/kiraop:v0.0.2
/home/kirater/operators/kiraop/bin/kustomize build config/manifests | /usr/local/bin/operator-sdk generate bundle -q --overwrite --version 0.0.1
INFO[0000] Creating bundle.Dockerfile
INFO[0000] Creating bundle/metadata/annotations.yaml
INFO[0000] Bundle metadata generated successfully
/usr/local/bin/operator-sdk bundle validate ./bundle
INFO[0000] All validation tests have completed successfull
```

To complete the procedure, let's create the all-in-one release file, named
`v0.0.2.yaml`:

```console
$ bin/kustomize build config/manifests --output v0.0.2.yaml
(no output)
```

And commit everything as before:

```console$ git status
$ git status
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   bundle/manifests/kiraop.clusterserviceversion.yaml
        modified:   config/manager/kustomization.yaml
        modified:   roles/akit/tasks/main.yml
Untracked files:
  (use "git add <file>..." to include in what will be committed)
        v0.0.2.yaml

no changes added to commit (use "git add" and/or "git commit -a")

$ git add . && git commit -m "Version v0.0.2"
[main 579d180] Version v0.0.2
 Date: Thu Aug 29 10:41:22 2024 +0000
 4 files changed, 529 insertions(+), 3 deletions(-)
 create mode 100644 v0.0.2.yaml
```

Now everything is tracked.

## Deploying specific releases

To apply the new release into the cluster, the `v0.0.2.yaml` can be passed as is
to `kubectl`, that will configure just the changed parts (usually the controller
manager deployment):

```console
$ kubectl apply -f v0.0.2.yaml
...
clusterrolebinding.rbac.authorization.k8s.io/kiraop-proxy-rolebinding unchanged
service/kiraop-controller-manager-metrics-service unchanged
deployment.apps/kiraop-controller-manager configured
...
```

The new deployment will be started and once it will come up the old one will be
terminated:

```console
NAME                                             READY   STATUS        RESTARTS   AGE
pod/kiraop-controller-manager-67647ddd67-b4nfd   2/2     Running       0          33s
pod/kiraop-controller-manager-74c5b64f64-d658z   2/2     Terminating   0          28m
```

To verify everything is working force a custom resource creation as follows:

```console
$ cat <<EOF | kubectl apply -f -
apiVersion: kiratech.it/v1alpha1
kind: Akit
metadata:
  name: akit-sample
spec:
  akit_namespace: mions
  akit_expose_lb: true
EOF

$ kubectl --namespace mions get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/akit-7758f87b8b-7d665   1/1     Running   0          24s

NAME              TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
service/akit      ClusterIP      10.96.180.87    <none>           80/TCP         30m
service/akit-lb   LoadBalancer   10.111.247.71   192.168.99.220   80:30908/TCP   30m

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/akit   1/1     1            1           30m

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/akit-5cf7b8469    0         0         0       30m
replicaset.apps/akit-7758f87b8b   1         1         1       24s

$ curl 192.168.99.220
This is my faboulous Webserver inside mions!
```

The last output shows the expected `v0.0.2` behavior.
