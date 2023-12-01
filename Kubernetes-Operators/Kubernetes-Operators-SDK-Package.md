# Lab | Manage Ansible Operator packages

## Make the original working directory a Git repository

```console
$ cd kiraop && git init
Initialized empty Git repository in /home/kirater/operators/kiraop/.git/

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

It is time to generate the first bundle for version `0.0.1`:

```console
$ make bundle IMG=quay.io/mmul/kiraop:v0.0.1
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
> rasca:raoul.scarazzini@kiratech.it

cd config/manager && /home/kirater/operators/kiraop/bin/kustomize edit set image controller=quay.io/mmul/kiraop:v0.0.1
/home/kirater/operators/kiraop/bin/kustomize build config/manifests | /usr/local/bin/operator-sdk generate bundle -q --overwrite --version 0.0.1
INFO[0000] Creating bundle.Dockerfile
INFO[0000] Creating bundle/metadata/annotations.yaml
INFO[0000] Bundle metadata generated successfully
/usr/local/bin/operator-sdk bundle validate ./bundle
INFO[0000] All validation tests have completed successfully
```

**TODO**: integrate `git status` and `git commit` for better understanding the
next step.

## Getting a specific version

To get a specific version, dump the `kustomize` output into a specific file:

```console
$ /home/kirater/operators/kiraop/bin/kustomize build config/manifests --output v0.0.1.yaml
(no output)
```

And commit everything.

```console
$ git add . && git commit -m "Version 0.0.1"
```

## Generate a new version

Change `` by adding:

```yaml
- name: Create Akit Deployment.
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
                ports:
                  - containerPort: 80
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
$ vim roles/akit/tasks/main.yml

$ make docker-build docker-push IMG=quay.io/mmul/kiraop:v0.0.2

$ make bundle IMG=quay.io/mmul/kiraop:v0.0.2
/usr/local/bin/operator-sdk generate kustomize manifests -q
cd config/manager && /home/kirater/operators/kiraop/bin/kustomize edit set image controller=quay.io/mmul/kiraop:v0.0.2
/home/kirater/operators/kiraop/bin/kustomize build config/manifests | /usr/local/bin/operator-sdk generate bundle -q --overwrite --version 0.0.1
INFO[0000] Creating bundle.Dockerfile
INFO[0000] Creating bundle/metadata/annotations.yaml
INFO[0000] Bundle metadata generated successfully
/usr/local/bin/operator-sdk bundle validate ./bundle
INFO[0000] All validation tests have completed successfull
```

```console
$ /home/kirater/operators/kiraop/bin/kustomize build config/manifests --output v0.0.2.yaml
(no output)
```

And its application into the cluster, that will configure just the changed parts
(usually the controller manager deployment):

```console
$ kubectl apply -f v0.0.4.yaml
...
clusterrolebinding.rbac.authorization.k8s.io/kiraop-proxy-rolebinding unchanged
service/kiraop-controller-manager-metrics-service unchanged
deployment.apps/kiraop-controller-manager configured
...
```

And check if the deployment of the CRD changes.
