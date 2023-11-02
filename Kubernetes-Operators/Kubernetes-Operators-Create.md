# Lab | Install Operator SDK

```bash
[kirater@training-kfs-minikube ~]$ mkdir kiraop

[kirater@training-kfs-minikube ~]$ cd kiraop/

[kirater@training-kfs-minikube kiraop]$ operator-sdk init --domain kiratech.it --plugins ansible
Writing kustomize manifests for you to edit...
Next: define a resource with:
$ operator-sdk create api

[kirater@training-kfs-minikube kiraop]$ ls
config  Dockerfile  Makefile  molecule  playbooks  PROJECT  requirements.yml  roles  watches.yaml
[kirater@training-kfs-minikube kiraop]$ ls roles

[kirater@training-kfs-minikube kiraop]$ operator-sdk create api --group cache --version v1alpha1 --kind Akit --generate-role
Writing kustomize manifests for you to edit...
[kirater@training-kfs-minikube kiraop]$ ls roles/
akit

File `roles/akit/tasks/main.yml`:

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
        namespace: "{{ akit_ns }}"
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

File `roles/akit/defaults/main.yml`:

```yaml
---
# defaults file for Akit
akit_insecure: false
akit_namespace: 'akit'
akit_container: 'public.ecr.aws/nginx/nginx:latest'
akit_expose_lb: true
```

Build the container:

```
[kirater@training-kfs-minikube kiraop]$ make docker-build
...
```

```
[kirater@training-kfs-minikube kiraop]$ grep ^IMAGE_TAG_BASE Makefile
IMAGE_TAG_BASE ?= quay.io/mmul/kiraop

[kirater@training-kfs-minikube kiraop]$ grep ^IMG Makefile
IMG ?= $(IMAGE_TAG_BASE):$(VERSION)

[kirater@training-kfs-minikube kiraop]$ cat config/rbac/role.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: manager-role
rules:
  ##
  ## Base operator rules
  ##
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
```

```
[kirater@training-kfs-minikube kiraop]$ docker login quay.io -u 'mmul+kiraop'
Password:
WARNING! Your password will be stored unencrypted in /home/kirater/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

[kirater@training-kfs-minikube kiraop]$ make docker-build docker-push
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

Install the operator:

```
[kirater@training-kfs-minikube kiraop]$ make deploy
cd config/manager && /home/kirater/kiraop/bin/kustomize edit set image controller=controller:latest
/home/kirater/kiraop/bin/kustomize build config/default | kubectl apply -f -
namespace/kiraop-system created
customresourcedefinition.apiextensions.k8s.io/akits.cache.kiratech.it unchanged
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


[kirater@training-kfs-minikube kiraop]$ kubectl -n kiraop-system get all
NAME                                             READY   STATUS    RESTARTS   AGE
pod/kiraop-controller-manager-7c7cd5dd7f-h8fkn   2/2     Running   0          26s

NAME                                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kiraop-controller-manager-metrics-service   ClusterIP   10.107.195.51   <none>        8443/TCP   26s

NAME                                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/kiraop-controller-manager   1/1     1            1           26s

NAME                                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/kiraop-controller-manager-7c7cd5dd7f   1         1         1       26s

```

Check the CRD:

```
[kirater@training-kfs-minikube kiraop]$ kubectl get crd | grep akit
akits.cache.kiratech.it                               2023-11-02T17:19:06Z
```

Create a CRD:

```
[kirater@training-kfs-minikube kiraop]$ cat << EOF | kubectl apply -f -
apiVersion: cache.kiratech.it/v1alpha1
kind: Akit
metadata:
  name: akit-sample
spec:
  akit_namespace: mions
  akit_expose_lb: true
EOF
akit.cache.kiratech.it/akit-sample created
```

```
[kirater@training-kfs-minikube kiraop]$ kubectl get akit
NAME          AGE
akit-sample   16s
```

```



*** TODO: add bits to make `kubectl explain akits.cache.kiratech.it` a useful
    output check config/crd/bases/cache.kiratech.it_akits.yaml ***

*** TODO: new versions with `VERSION=0.0.2 make docker-build docker-push` ***
