# Introduction to Kubernetes - Wrap up test

## Install minikube

Following the [official instructions](https://minikube.sigs.k8s.io/docs/start/)
or the [Kubernetes-Install-Minikube.md](Kubernetes-Install-Minikube.md) install
Minikube in your local environment.

In Linux, this should be as simple as:

```sh
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
...

$ sudo install minikube-linux-amd64 /usr/local/bin/minikube
(no output)

$ minikube delete
🔥  Deleting "minikube" in docker ...
🔥  Deleting container "minikube" ...
🔥  Removing /home/rasca/.minikube/machines/minikube ...
💀  Removed all traces of the "minikube" cluster.
rasca@lens:~$ minikube start
😄  minikube v1.28.0 on Ubuntu 20.04 (kvm/amd64)
✨  Automatically selected the docker driver
📌  Using Docker driver with root privileges
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🐳  Preparing Kubernetes v1.25.3 on Docker 20.10.20 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass, storage-provisioner
💡  kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

$ alias kubectl="minikube kubectl --"
(no output)
```

## Activate ingress plugin for minikube

Following the [official instructions](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#enable-the-ingress-controller)
enable the ingress addon for Minikube, necessary to complete this test.

In Linux, this should be as simple as:

```sh
$ minikube addons enable ingress
💡  ingress is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
    ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
    ▪ Using image k8s.gcr.io/ingress-nginx/controller:v1.2.1
🔎  Verifying ingress addon...
🌟  The 'ingress' addon is enabled
```

## Get Minikube IP

Once Minikube is installed and running, extract the IP address of the Minikube
virtual machine, using this command:

```sh
$ minikube ip
192.168.49.2
```

This will be used to define a way to access the services exposed by Minikube.

By using the nip.io wildcard DNS service it will be possible to define an
address to be used by the exercise based on this IP:

```sh
$ ping 192.168.49.2.nip.io
PING 192.168.49.2.nip.io (192.168.49.2) 56(84) bytes of data.
64 bytes from 192.168.49.2 (192.168.49.2): icmp_seq=1 ttl=64 time=0.226 ms
64 bytes from 192.168.49.2 (192.168.49.2): icmp_seq=2 ttl=64 time=0.106 ms
^C
--- 192.168.49.2.nip.io ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.106/0.166/0.226/0.060 ms
```

In this case the reference url is `192.168.49.2.nip.io` that is resolved with
the `192.168.49.2` IP address.

## Download the yaml application

Locally download the [Wrap up exercise yaml file](Kubernetes-From-Scratch-Wrap-Up-Test.yaml).

## Change the host address of the ingress element

Inside the downloaded file change the `spec:` -> `rules:` -> `host:` value to
the address defined above.

You can automate this operation, in Linux, by doing:

```sh
$ sed -i -e 's/host: .*/host: 192.168.49.2.nip.io/g' Exercise.Wrap-up.yaml
(no output)
```

## Create the Kubernetes resources

Using `kubectl` load the downloaded yaml into the Minikube Kubernetes cluser:

```sh
$ kubectl create -f Exercise.Wrap-up.yaml
namespace/myingress-test created
configmap/docroot created
pod/mywebserver created
service/mywebserver-svc created
ingress.networking.k8s.io/mywebserver-ingress created
```

This will create a namespace named `myingress-test` with some resources.

## Check the results #1

**Which resources have been created?**

Use `kubectl -n myingress-test get all,ingress` to track which resources have
been created in the Minikube cluster.

## Check the results #2

**What is the output of the exposed service?**

Use `curl http://192.168.49.2.nip.io` (changing the url depending on your
installation to track what is the output produced by the service.
