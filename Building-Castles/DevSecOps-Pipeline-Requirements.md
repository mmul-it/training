# Lab | Set the requirements

The following setup outlines the requirements for the entire lab that will be
developed during the Building Castles course.

## Docker

Docker is a requirement for all the labs and the entire DevSecOps environment
configuration, so depending on the operating system in use the `docker` packages
need to be installed. [You can follow these instructions](../Common/Containers-Install-Docker.md).

The docker daemon must be in execution, check it by executing:

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

Now, you should be able to launch containers:

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

All services deployed throughout the labs operate as containers on a host. This
means that each service's port will be exposed on the Docker host using the
`--publish` option, allowing the port to listen on localhost as well
as any other interface on the host.

To ensure that services can communicate between containers, it is essential
to use an IP address other than `localhost` (`127.0.0.1`).
Since everything will run on the same host, the best approach to enable
communication between containers is creating an IP associated with the `lo`
interface, like `172.16.99.1`.

```console
$ sudo ip address add 172.16.99.1 dev lo
(no output)
```

The IP `172.16.99.1` must be used as a reference for the services
configurations.

NOTE: you might want to choose a different IP or a different device. It is possible
to list all the machine's IP addresses using the `ip address show` command.

## Insecure registries

We will set up a registry using `Nexus` with SSL, employing a self-signed
certificate. To ensure that the repository is recognized by the Docker client, it
must be added (as `root`) to the `/etc/docker/daemon.json` file, containing the
following content:

```json
{
       "insecure-registries" : ["172.16.99.1:5000"]
}
```

The docker daemon must be restarted after this change:

```console
$ sudo systemctl restart docker
(no output)
```

## Minikube

Once the pipeline is complete, a registry will be available at the
`172.16.99.1:5000` address, which can also be utilized by Kubernetes.

Since we will rely on a self-signed certificate and manage Kubernetes using
Minikube, it must be started with the proper `--insecure-registry` option.

Therefore, after installing Minikube (following the [Install Minikube](../Common/Kubernetes-Install-Minikube.md) lab) we must start it in the following way:

```console
$ minikube start --insecure-registry=172.16.99.1:5000
...
```
