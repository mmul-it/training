# Lab | Create an Ansible Operator

In this lab you will create a working Ansible based operator that will enable a
specific Custom Resource to automate application deployments.

## Operator's initialization

Initialize the operator's main directory by using the `operator-sdk init`
command. The domain of our operator will be `kiratech.it`:

```bash
$ mkdir -v kiraop && cd kiraop/
mkdir: created directory 'kiraop'

$ operator-sdk init --domain kiratech.it --plugins ansible
Writing kustomize manifests for you to edit...
Next: define a resource with:
$ operator-sdk create api
```

The initialization will produce some content inside the directory that will
serve as the operator's working directory:

```bash
kiraop/
├── Dockerfile
├── LICENSE
├── Makefile
├── PROJECT
├── config           (d)
├── molecule         (d)
├── playbooks        (d)
├── requirements.yml
├── roles            (d)
└── watches.yaml

4 directories, 6 files
```

The operator will rely on a custom Ansible role that will be part of the group
`cache` with version `v1alpha1`. Role will be named after the Custom Resource
name, in this case `Akit`, and initialized by the `operator-sdk create api`
command:

```bash
$ ls roles
(no output)

$ operator-sdk create api --version v1alpha1 --kind Akit --generate-role
Writing kustomize manifests for you to edit...

$ tree roles/
roles/
└── akit
    ├── README.md
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── tasks
    │   └── main.yml
    ├── templates
    └── vars
        └── main.yml

8 directories, 6 files
```

What will effectively be done by the operator will be defined inside the file
`roles/akit/tasks/main.yml` which will contain the Operator's logic:

```yaml
---
# tasks file for Akit
- name: Ensure the Akit Namespace exists.
  kubernetes.core.k8s:
    api_version: v1
    kind: Namespace
    name: "{{ akit_namespace }}"
    state: present

- name: Create Akit Deployment.
  kubernetes.core.k8s:
    state: present
    resource_definition:
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        labels:
          app: akit
        name: akit
        namespace: "{{ akit_namespace }}"
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

- name: Create Akit Service.
  kubernetes.core.k8s:
    state: present
    resource_definition:
      apiVersion: v1
      kind: Service
      metadata:
        labels:
          app: akit
        name: akit
        namespace: "{{ akit_namespace }}"
      spec:
        ports:
          - name: http
            port: 80
            protocol: TCP
            targetPort: 80
        selector:
          app: akit

- name: Create Akit LB service.
  kubernetes.core.k8s:
    state: present
    resource_definition:
      apiVersion: v1
      kind: Service
      metadata:
        name: akit-lb
        namespace: "{{ akit_namespace }}"
      spec:
        type: LoadBalancer
        selector:
          app: akit
        ports:
          - port: 80
            protocol: TCP
            targetPort: 80

  when:
    - akit_expose_lb | bool
```

So, every `Akit` Custom Resource will be a group composed by a `namespace`, a
`deployment`, and two services, a `ClusterIP` (default) one and a
`LoadBalancer`.

Defaults will be defined under `roles/akit/defaults/main.yml`:

```yaml
---
# defaults file for Akit
akit_insecure: false
akit_namespace: 'akit'
akit_container: 'public.ecr.aws/nginx/nginx:latest'
akit_expose_lb: true
```

To define the permissions needed by the operator the `config/rbac/role.yaml`
must be edited. In the proposed example the operator should have powers to
create a lot of resources, so the first rule of the list should be edited to
contain extended `resources`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: manager-role
rules:
  - apiGroups:
      - ""
    resources:
      - namespaces
      - ingresses
      - deployments
      - services
      - secrets
      - pods
      - pods/exec
      - pods/log
...
...
```

## Operator's container image build

With everything in place it is time to build the operator container. Since the
container will be pushed somewhere in a public registry, a specific name needs
to be set.

The `IMAGE_TAG_BASE` and `IMG` should not change during the life cycle of the
operator, so can be hard-coded inside the `Makefile`:

```console
$ sed -i -e 's/^IMAGE_TAG_BASE ?= .*/IMAGE_TAG_BASE ?= quay.io\/mmul\/kiraop/g' Makefile
(no output)

$ grep ^IMAGE_TAG_BASE Makefile
IMAGE_TAG_BASE ?= quay.io/mmul/kiraop

$ sed -i -e 's/^IMG ?= .*/IMG ?= $(IMAGE_TAG_BASE):$(VERSION)/g' Makefile
(no output)

$ grep ^IMG Makefile
IMG ?= $(IMAGE_TAG_BASE):$(VERSION)
```

This will make us able to pass just the `VERSION` parameter in the next
commands.

It is mandatory to have login powers to the destination registry, and this can
be achieved by using `docker login`:

```console
$ docker login quay.io -u 'mmul+kiraop'
Password:
WARNING! Your password will be stored unencrypted in /home/kirater/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

Not it is time to effectively build and push the operator container image:

```console
$ VERSION=v0.0.1 make docker-build docker-push
docker build -t quay.io/mmul/kiraop:0.0.1 .
[+] Building 0.8s (11/11) FINISHED                                                        docker:default
 => [internal] load build definition from Dockerfile
...
...
docker push quay.io/mmul/kiraop:0.0.1
The push refers to repository [quay.io/mmul/kiraop]
40112080b803: Pushed
3ef22fa65bd4: Pushed
ad3524b33cdd: Pushed
8a4ecb6fa7a9: Pushed
e643d0a73d6f: Pushed
d558eb29f828: Mounted from operator-framework/ansible-operator
5f70bf18a086: Mounted from operator-framework/ansible-operator
b2280ff3b4f1: Mounted from operator-framework/ansible-operator
35f39bef42b5: Mounted from operator-framework/ansible-operator
e52bf27270ec: Mounted from operator-framework/ansible-operator
816eef7f4aac: Mounted from operator-framework/ansible-operator
18e82a61fc56: Mounted from operator-framework/ansible-operator
fe69b5b7445f: Mounted from operator-framework/ansible-operator
00e0d697268b: Mounted from operator-framework/ansible-operator
815ca85c5fa5: Mounted from operator-framework/ansible-operator
0.0.1: digest: sha256:5faf62fc61e1d27289184aadc4413b4cbaa0482dcf0a2506d8ae5d90a64c43c3 size: 3452
```

Since the image is available the operator can be installed by using
`make deploy`. This will try to install everything inside the default Kubernetes
cluster accessible via `kubectl`:

```console
$ VERSION=v0.0.1 make deploy
cd config/manager && /home/kirater/kiraop/bin/kustomize edit set image controller=quay.io/mmul/kiraop:v0.0.1
/home/kirater/kiraop/bin/kustomize build config/default | kubectl apply -f -
namespace/kiraop-system created
customresourcedefinition.apiextensions.k8s.io/akits.kiratech.it created
serviceaccount/kiraop-controller-manager created
role.rbac.authorization.k8s.io/kiraop-leader-election-role created
clusterrole.rbac.authorization.k8s.io/kiraop-manager-role created
clusterrole.rbac.authorization.k8s.io/kiraop-metrics-reader created
clusterrole.rbac.authorization.k8s.io/kiraop-proxy-role created
rolebinding.rbac.authorization.k8s.io/kiraop-leader-election-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/kiraop-manager-rolebinding created
clusterrolebinding.rbac.authorization.k8s.io/kiraop-proxy-rolebinding created
service/kiraop-controller-manager-metrics-service created
deployment.apps/kiraop-controller-manager created
```

Monitoring the status of the resources inside the `kiraop-system` namespace will
tell when the operator is ready:

```console
$ kubectl -n kiraop-system get all
NAME                                             READY   STATUS    RESTARTS   AGE
pod/kiraop-controller-manager-7c7cd5dd7f-h8fkn   2/2     Running   0          26s

NAME                                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kiraop-controller-manager-metrics-service   ClusterIP   10.107.195.51   <none>        8443/TCP   26s

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kiraop-controller-manager   1/1     1            1           26s

NAME                                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/kiraop-controller-manager-7c7cd5dd7f   1         1         1       26s
```

And the relative CRD available:

```console
[kirater@training-kfs-minikube kiraop]$ kubectl get crd | grep akit
akits.kiratech.it                                      2024-08-28T15:13:54Z
```

## Operator's tests

Testing the operator is possible by creating its CRD:

```console
[kirater@training-kfs-minikube kiraop]$ cat << EOF | kubectl apply -f -
apiVersion: kiratech.it/v1alpha1
kind: Akit
metadata:
  name: akit-sample
spec:
  akit_namespace: mions
  akit_expose_lb: true
EOF
akit.cache.kiratech.it/akit-sample created
```

And monitor everything:

```console
[kirater@training-kfs-minikube kiraop]$ kubectl get akit
NAME          AGE
akit-sample   16s

[kirater@training-kfs-minikube kiraop]$ kubectl -n mions get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/akit-768dbfc955-xcpcg   1/1     Running   0          16s

NAME              TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
service/akit      ClusterIP      10.100.144.58   <none>           80/TCP         13s
service/akit-lb   LoadBalancer   10.102.202.28   192.168.99.101   80:31147/TCP   11s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/akit   1/1     1            1           16s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/akit-768dbfc955   1         1         1       16s
```

And, just for fun:

```console
[kirater@training-kfs-minikube kiraop]$ curl -s 192.168.99.101 | grep Welcome
<title>Welcome to nginx!</title>
<h1>Welcome to nginx!</h1>
```

## Documenting the operator's Custom Resource

A user that wants to get details about the operator's Custom Resource will
use `kubectl explain` as follows:

```console
[kirater@training-kfs-minikube kiraop]$ kubectl explain akits.kiratech.it
GROUP:      kiratech.it
KIND:       Akit
VERSION:    v1alpha1

DESCRIPTION:
    Akit is the Schema for the akits API

FIELDS:
  apiVersion    <string>
    APIVersion defines the versioned schema of this representation of an object.
    Servers should convert recognized schemas to the latest internal value, and
    may reject unrecognized values. More info:
    https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
...
...
```

The content of this was generated by the SDK and can be customized by editing
the `config/crd/bases/kiratech.it_akits.yaml` file.

## Deploying a specific operator's version

It is important to note how specific operator versions can be created or
deployed by using the `VERSION` environmental variable.

To build and push a new version of the operator:

```console
$ VERSION=0.0.2 make docker-build docker-push
...
...
```

This will produce an image named `quay.io/mmul/kiraop:0.0.2` and to deploy it:

```console
$ VERSION=0.0.2 make deploy
cd config/manager && /home/kirater/operators/kiraop/bin/kustomize edit set image controller=quay.io/mmul/kiraop:0.0.3
/home/kirater/operators/kiraop/bin/kustomize build config/default | kubectl apply -f -
...
...
```

It is useful to remember the role of the `latest` tag, which represents the
latest deployed image.
