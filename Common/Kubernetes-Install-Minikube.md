# Lab | Install Minikube

In this lab you will install Minikube to get a working Kubernetes cluster.

## Check requirements

Your system should have, at least:

- 2 CPUs or more.
- 2GB of free memory.
- 20GB of free disk space.
- Internet connection.
- Container or virtual machine manager, such as: Docker, QEMU, Hyperkit,
  Hyper-V, KVM, Parallels, Podman, VirtualBox, or VMware Fusion/Workstation.

In case of a Linux host a good idea would be to use Minikube through Docker.
Instructions on how to install and enable a user to run Docker are available at
[Containers-Install-Docker.md](Containers-Install-Docker.md).

## Download Minikube

Download and make it executable in `/usr/local/bin`:

```console
$ curl -O https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
...

$ chmod -v +x minikube-linux-amd64
mode of 'minikube-linux-amd64' changed from 0664 (rw-rw-r--) to 0775 (rwxrwxr-x)
```

Copy the binary in your $PATH:

```console
$ sudo mv -v minikube-linux-amd64 /usr/local/bin/minikube
renamed 'minikube-linux-amd64' -> '/usr/local/bin/minikube'
```

## Start Minikube

Start minikube:

```console
$ minikube start
😄  minikube v1.28.0 on Linuxmint 21
✨  Automatically selected the docker driver. Other choices: kvm2, ssh, qemu2 (experimental)
📌  Using Docker driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.25.3 preload ...
    > preloaded-images-k8s-v18-v1...:  385.44 MiB / 385.44 MiB  100.00% 3.14 Mi
🔥  Creating docker container (CPUs=2, Memory=7900MB) ...
🐳  Preparing Kubernetes v1.25.3 on Docker 20.10.20 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
💡  kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

```

### Enable a specific insecure registry in Minikube

If you need to enable a specific insecure registry in your Minikube
installation, like it's needed for the **Building Castles** training series, it
is possible to pass the `--insecure-registries` option:

```console
$ minikube start --insecure-registry=172.16.99.1:5000
...
```

This will consider `172.16.99.1:5000` container registry as an usable one inside
the Minikube installation.

### Enable a specific CNI in Minikube

If you need to use a different CNI plugin in your Minikube installation it is
possible to pass the `--cni` option, chosing the proper plugin.

For the **Shifting Kubernetes left** security workshop a good choice would be
`calico`, so the proper command line to install Minikube would be:

```console
$ minikube start  --cni calico
...
```

This will improve the way Minikube manages the Network, by supporting features
like _Network Policies_.

## Enable kubectl

Download the `kubectl` command:

```console
$ minikube kubectl -- get po -A
    > kubectl.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubectl:  42.93 MiB / 42.93 MiB [--------------] 100.00% 3.49 MiB p/s 13s
NAMESPACE     NAME                               READY   STATUS    RESTARTS        AGE
kube-system   coredns-565d847f94-bxrb6           1/1     Running   0               2m38s
kube-system   etcd-minikube                      1/1     Running   0               2m52s
kube-system   kube-apiserver-minikube            1/1     Running   0               2m52s
kube-system   kube-controller-manager-minikube   1/1     Running   0               2m51s
kube-system   kube-proxy-pjz5z                   1/1     Running   0               2m38s
kube-system   kube-scheduler-minikube            1/1     Running   0               2m52s
kube-system   storage-provisioner                1/1     Running   2 (2m38s ago)   2m51s
```

Make it available in your shell:

```console
$ find .minikube/ -name kubectl
.minikube/cache/linux/amd64/v1.25.3/kubectl

$ echo 'PATH=.minikube/cache/linux/amd64/v1.30.0/:$PATH' >> ~/.bash_profile
(no output)

$ export PATH=.minikube/cache/linux/amd64/v1.30.0/:$PATH
(no output)

$ kubectl get po -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS     AGE
kube-system   coredns-565d847f94-bxrb6           1/1     Running   0            6m
kube-system   etcd-minikube                      1/1     Running   0            6m14s
kube-system   kube-apiserver-minikube            1/1     Running   0            6m14s
kube-system   kube-controller-manager-minikube   1/1     Running   0            6m13s
kube-system   kube-proxy-pjz5z                   1/1     Running   0            6m
kube-system   kube-scheduler-minikube            1/1     Running   0            6m14s
kube-system   storage-provisioner                1/1     Running   2 (6m ago)   6m13s
```

## Extend kubectl functionalities

There are plenty of ways to extend `kubectl` functionalies, follow
[Kubernetes-Kubectl-Improvements.md](Kubernetes-Kubectl-Improvements.md)
to activate some of them.
