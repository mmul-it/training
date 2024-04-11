# Argo CD Workshop - Stage 1

## Create three Kind instances

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
