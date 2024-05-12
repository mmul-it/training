# Lab | Containers Run Modes

In this lab you will:

1. Pull the image "hello-world" from the docker registry.
2. Pull the image "nginx" form the docker registry.
3. Run in one-time mode the "hello-world" container and observe its behavior.
4. Run in one-time mode the "nginx" container and observe its behavior.
5. What are the differences?
6. Run in detached mode the "hello-world" container.
7. Run in detached mode the "nginx" container.
8. What are the differences?

## Solution

1. Log into minikube and pull the hello-world image:

   ```console
   $ minikube ssh

   docker@minikube:~$ docker pull hello-world
   Using default tag: latest
   latest: Pulling from library/hello-world
   2db29710123e: Pull complete
   Digest: sha256:faa03e786c97f07ef34423fccceeec2398ec8a5759259f94d99078f264e9d7af
   Status: Downloaded newer image for hello-world:latest
   docker.io/library/hello-world:latest
   ```

2. Do the same for nginx:

   ```console
   docker@minikube:~$ docker pull nginx
   Using default tag: latest
   latest: Pulling from library/nginx
   a603fa5e3b41: Pull complete
   c39e1cda007e: Pull complete
   90cfefba34d7: Pull complete
   a38226fb7aba: Pull complete
   62583498bae6: Pull complete
   9802a2cfdb8d: Pull complete
   Digest: sha256:e209ac2f37c70c1e0e9873a5f7231e91dcd83fdf1178d8ed36c2ec09974210ba
   Status: Downloaded newer image for nginx:latest
   docker.io/library/nginx:latest
   ```

3. Run the first container with `docker run`:

   ```console
   docker@minikube:~$ docker run --rm hello-world

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

4. Run the second as well:

   ```console
   docker@minikube:~$ docker run --rm nginx
   /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
   /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
   10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
   10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
   /docker-entrypoint.sh: Configuration complete; ready for start up
   2022/12/02 14:18:59 [notice] 1#1: using the "epoll" event method
   2022/12/02 14:18:59 [notice] 1#1: nginx/1.23.2
   2022/12/02 14:18:59 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
   2022/12/02 14:18:59 [notice] 1#1: OS: Linux 5.15.0-56-generic
   2022/12/02 14:18:59 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
   2022/12/02 14:18:59 [notice] 1#1: start worker processes
   2022/12/02 14:18:59 [notice] 1#1: start worker process 29
   2022/12/02 14:18:59 [notice] 1#1: start worker process 30
   2022/12/02 14:18:59 [notice] 1#1: start worker process 31
   2022/12/02 14:18:59 [notice] 1#1: start worker process 32
   2022/12/02 14:18:59 [notice] 1#1: start worker process 33
   2022/12/02 14:18:59 [notice] 1#1: start worker process 34
   2022/12/02 14:18:59 [notice] 1#1: start worker process 35
   2022/12/02 14:18:59 [notice] 1#1: start worker process 36
   2022/12/02 14:18:59 [notice] 1#1: start worker process 37
   2022/12/02 14:18:59 [notice] 1#1: start worker process 38
   2022/12/02 14:18:59 [notice] 1#1: start worker process 39
   2022/12/02 14:18:59 [notice] 1#1: start worker process 40
   2022/12/02 14:18:59 [notice] 1#1: start worker process 41
   2022/12/02 14:18:59 [notice] 1#1: start worker process 42
   2022/12/02 14:18:59 [notice] 1#1: start worker process 43
   2022/12/02 14:18:59 [notice] 1#1: start worker process 44
   ```

5. The main difference is that to exit from the nginx one you need to Ctrl+C or stop the container from another terminal.

6. Using `--detach` as option re-running the first container:

   ```console
   docker@minikube:~$ docker run --rm --detach hello-world
   996327f18193cc1c65909271f2e427fb243fb56662c9c768e1b6205dfbf57243
   ```

7. Do the same with the second one:

   ```console
   docker@minikube:~$ docker run --rm --detach nginx
   3de0f47598d1e6836769380e24414b3fe0036028b25f363d659ff4210d718414
   ```

8. Running `docker ps` will show *just* the nginx container, because the first one even if it was launched with `--detach` is meant just for a one time execution (showing the message you see while running in foreground):

   ```console
   docker@minikube:~$ docker ps | grep hello-world

   docker@minikube:~$ docker ps | grep nginx
   3de0f47598d1   nginx                  "/docker-entrypoint.…"   45 seconds ago   Up 44 seconds   80/tcp    reverent_shamir
   ```
