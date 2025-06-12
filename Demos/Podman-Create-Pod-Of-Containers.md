# Demonstration | Podman: create a pod of containers

A pod can be created as a standalone object:

```console
$ podman pod create --name mypod
080d044bd0e27d5451715638a9537395db63458aed21815388ea8b911f51a1f5
```

Podman will create a container named "pause" that will justify the pod
existance:

```console
$ podman ps -a
CONTAINER ID  IMAGE                 COMMAND  CREATED         STATUS   PORTS   NAMES
4a3518bb78c8  k8s.gcr.io/pause:3.2           27 seconds ago  Created          080d044bd0e2-infra
```

Then it will be possible to create containers inside the pod, like this:

```console
$ podman run --detach --pod mypod --name mynginx \
    quay.io/libpod/alpine_nginx:latest
07872490612e5615d4bc21f266bdbb7de28cb99fa0bd2059b29b43e0b327d3fd
```

```console
$ podman run --detach --pod mypod --name mymariadb \
    --env MARIADB_ROOT_PASSWORD=mypassword mariadb:latest
1bcb29fb46c24c5257998129ce7a8998b8a62fef77047bc2b30a6623f4ff928d
```

Containers whithin the same pod will share the same namespace, also the network
one:

```console
$ podman exec --interactive --tty mynginx /bin/sh
# ping -c 2 mymariadb
PING mymariadb (127.0.1.1): 56 data bytes
64 bytes from 127.0.1.1: seq=0 ttl=64 time=0.047 ms
64 bytes from 127.0.1.1: seq=1 ttl=64 time=0.052 ms

--- mymariadb ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.047/0.049/0.052 ms
/ # nc -v mymariadb 3306
mymariadb (127.0.1.1:3306) open
o
5.5.5-10.5.11-MariaDB-1:10.5.11+maria~focalZ.u%ROv'��-��[u]Q\]>^<Rf,mysql_native_password
```

**NOTE 1**: the two addresses for mynginx and mymariadb will be both
`127.0.0.1`, this means that a pod can be associated entirely to `localhost`.

**NOTE 2**: a pod can be implicitly created by using the `--pod new:<podname>`,
like:

```console
$ podman run --detach --pod new:mypod \
    --env MARIADB_ROOT_PASSWORD=password \
    mariadb:latest
1bdwdeedwedwdewwe342323238129ce7a8998b8a62fef77047bc2b30a6623f4f
```
