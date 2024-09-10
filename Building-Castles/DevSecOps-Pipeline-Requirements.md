# Lab | Set the requirements

This lab defines the requirements for the entire lab that will be used during
the Building Castles course.

## Docker

Docker is a requirement for all the exercises and the entire DevSecOps
environment configuration, so depending on the operating system the `docker`
packages need to be installed, [you can follow these instructions](../Common/Containers-Install-Docker.md).

The docker daemon must be in execution, check it by:

```console
$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; disabled; vendor preset: enabled)
     Active: active (running) since Wed 2023-06-21 10:26:41 CEST; 4h 8min ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 23750 (dockerd)
      Tasks: 122
     Memory: 2.0G
        CPU: 1min 29.063s
...
```

And you should be able to launch containers:

```console
$ docker run --rm hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete
Digest: sha256:4bd78111b6914a99dbc560e6a20eab57ff6655aea4a80c50b0c5491968cbc2e6
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

## IP address

All the services deployed in this lab will run as containers on a host.
This means that each service port will be published on the docker host, by
using `--publish` option, that will make the port listen on `localhost` and
any other interface on the host.
To make services reachable between containers it is mandatory to use an IP
different from `localhost` (`127.0.0.1`).
Since everything will run on the same host, best way to achieve overall
reachableness is by creating an IP associated with `lo` interface, like
`172.16.99.1`.

```console
> sudo ip address add 172.16.99.1 dev lo
```

The IP `172.16.99.1` must be used as a reference for the services
configurations.

NOTE: you might want to chose a different IP or a different device. It is
possible to list all the machine IP using the `ip address show` command.

## Insecure registries

We will configure a registry by using `Nexus` via SSL, by using a self signed
certificate. To make the repository accepted by the docker client, it must be
added (as `root`) to the `/etc/docker/daemon.json` file, with this content:

```json
{
       "insecure-registries" : ["172.16.99.1:5000"]
}
```

The docker daemon must be restarted after this change:

```console
> sudo systemctl restart docker
```

## Minikube

Once the pipeline will be complete, there will be a registry available at the
`172.16.99.1:5000` address, usable also by Kubernetes.

Since we will work on self-signed certificate and will manage Kubernetes
using Minikube, this must be started with the proper `--insecure-registries`
option.
As follows:

```console
> minikube start --insecure-registry=172.16.99.1:5000
```

Check the [Enable a specific insecure registry](https://gitlab.com/kiratech/labs/-/blob/gitlab-workshop/Common/Kubernetes-Install-Minikube.md#enable-a-specific-insecure-registry)
chapter of the [Install Minikube](https://gitlab.com/kiratech/labs/-/blob/gitlab-workshop/Common/Kubernetes-Install-Minikube.md) lab.
