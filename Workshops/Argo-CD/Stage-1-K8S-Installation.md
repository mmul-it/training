# Argo CD Workshop - Stage 1

The lab environment will be configured by using [Kind](https://kind.sigs.k8s.io/),
a tool that creates Kubernetes clusters inside containers.

First of all, the lab machine should have Docker installed. Instructions about
how to install Docker are [available here](../../Common/Containers-Install-Docker.md).

Once Docker is available, it will be possible to proceed.

## Fix system inotify settings

Because of the high number of processes that will be executed, some Linux system
tweaks are suggested:

```console
$ echo fs.inotify.max_user_watches=655360 | sudo tee -a /etc/sysctl.conf
fs.inotify.max_user_watches=655360

$ echo fs.inotify.max_user_instances=1280 | sudo tee -a /etc/sysctl.conf
fs.inotify.max_user_instances=1280

$ sudo sysctl -p
fs.inotify.max_user_watches = 655360
fs.inotify.max_user_instances = 1280
```

Check [this issue](https://github.com/kubernetes-sigs/kind/issues/2744) for
details.

## Install kind executable

Kind is a simple executable, downloading and putting it under a known path is
everything that needs to be done:

```console
$ [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
(no output)

$ chmod +x ./kind
(no output)

$ sudo mv ./kind /usr/local/bin/kind
(no output)
```

## Create the three Kubernetes cluster

The three Kubernetes clusters will be installed inside the default Kind subnet,
`172.18.0.0/24`, since we will need them to be reachable one to another.

The clusters will be exposed on the `172.18.0.1` IP, each one on a different
port:

- Cluster `kind-argo`, IP `172.18.0.1`, Port `6443`.
- Cluster `kind-test`, IP `172.18.0.1`, Port `7443`.
- Cluster `kind-prod`, IP `172.18.0.1`, Port `8443`.

To do so, a specific configuration file should be created for each instance,
and passed to the `kind create cluster` command.

For the `kind-argo` cluster (check [kind-argo-config.yml](kind-argo-config.yml)):

```console
$ cat <<EOF > kind-argo-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 6443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
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
```

For the `kind-test` cluster (check [kind-test-config.yml](kind-test-config.yml)):

```console
$ cat <<EOF > kind-test-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 7443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
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
```

For the `kind-prod` cluster (check [kind-prod-config.yml](kind-prod-config.yml)):

```console
$ cat <<EOF > kind-prod-config.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "172.18.0.1"
  apiServerPort: 8443
nodes:
- role: control-plane
  image: kindest/node:v1.29.2@sha256:51a1434a5397193442f0be2a297b488b6c919ce8a3931be0ce822606ea5ca245
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

## Kubernetes kubectl tool installation

The `kubectl` command is crucial for each kind of operation with Kubernetes.

Since `kubectl` is a pretty much complex tool, enabling its bash completion part
is more than helpful.

These steps install `kubectl` and enable the bash completion:

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

## Check the installed clusters

With `kubectl` in place it will be possible to get an overview of the installed
clusters:

```console
$ for K8S in argo test prod; do kubectl --context kind-$K8S get nodes; echo; done
NAME                 STATUS   ROLES           AGE   VERSION
argo-control-plane   Ready    control-plane   28h   v1.29.2

NAME                 STATUS   ROLES           AGE   VERSION
test-control-plane   Ready    control-plane   28h   v1.29.2

NAME                 STATUS   ROLES           AGE   VERSION
prod-control-plane   Ready    control-plane   28h   v1.29.2
```

Since everything is in place, it is possible to proceed with [Stage 2](Stage-2-MetalLB-Installation.md).
