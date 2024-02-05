# Lab | Install Docker

In this lab you will install Docker into your system.

## Install packages

Docker can be installed [following the official instructions](https://docs.docker.com/engine/install/).

### RHEL based distros

For RHEL based operating systems these are the steps to be followed:

```console
$ sudo yum install -y yum-utils
...

$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
Adding repo from: https://download.docker.com/linux/centos/docker-ce.repo

$ sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
...
```

### Debian based distros

For Debian based operating systems instead, the `apt` Docker repository needs
to be configured:

```console
$ sudo apt-get update
...

$ sudo apt-get -y install ca-certificates curl
...

$ sudo install -m 0755 -d /etc/apt/keyrings
(no output)

$ sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
(no output)

$ sudo chmod a+r /etc/apt/keyrings/docker.asc

$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
(no output)

$ sudo apt-get update
...
```

So that the packages can be installed:

```console
$ sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
...
```

## Configure services

The `docker` daemon should be started as follows:

```console
$ sudo systemctl start docker
(no output)

$ sudo systemctl enable docker
Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /usr/lib/systemd/system/docker.service.
```

Remember that your user must be part of the `docker` system group.
This can be done as follows:

```console
$ sudo usermod --append --groups docker kirater
(no output)

$ newgrp docker
(no output)

$ groups
docker kirater
```

## Test docker

The Docker installation can be tested as follows:

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

This means that Docker is working properly.
