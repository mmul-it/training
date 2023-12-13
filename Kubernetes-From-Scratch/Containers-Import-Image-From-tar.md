# Lab | Containers Import Image From tar

In this lab you will:

1. Download and uncompress the tar image named
   [Containers-Import-Image-From-tar.nginx-saved-container.tar.xz](https://github.com/mmul-it/training/raw/master/Kubernetes-From-Scratch/Containers-Import-Image-From-tar.nginx-saved-container.tar.xz)
2. *Load* the saved image into the docker registry;
3. Run a container starting from this image, exposing port `8080` and note what
   is different from a usual nginx;
4. Download and uncompress now the tar named
   [Containers-Import-Image-From-tar.nginx-exported-container.tar.xz](https://github.com/mmul-it/training/raw/master/Kubernetes-From-Scratch/Containers-Import-Image-From-tar.nginx-exported-container.tar.xz)
5. *Load* the image, what happens?
6. Now try to *import* the image, what happens?
7. Finally try to run a container based on this image, is this possible? Can you
   tell why?

## Solution

1. The file [Containers-Import-Image-From-tar.nginx-saved-container.tar.xz](https://github.com/mmul-it/training/raw/master/Kubernetes-From-Scratch/Containers-Import-Image-From-tar.nginx-saved-container.tar.xz)
   should be downloaded and uncompressed:

   ```console
   > curl -sL https://github.com/mmul-it/training/raw/master/Kubernetes-From-Scratch/Containers-Import-Image-From-tar.nginx-saved-container.tar.xz -o Containers-Import-Image-From-tar.nginx-saved-container.tar.xz

   > xz -d Containers-Import-Image-From-tar.nginx-saved-container.tar.xz
   ```

2. To load the image use `docker load`:

   ```console
   > docker load -i Containers-Import-Image-From-tar.nginx-saved-container.tar
   7b4e562e58dc: Loading layer [==================================================>]  58.44MB/58.44MB
   c9c2a3696080: Loading layer [==================================================>]  54.44MB/54.44MB
   b7efe781401d: Loading layer [==================================================>]  3.584kB/3.584kB
   4191b1f8c2d7: Loading layer [==================================================>]  13.82kB/13.82kB
   Loaded image: nginx-saved-container:latest
   ```

3. To run the image use `docker run` publishing the `8080` port on localhost:

   ```console
   > docker run --detach --name imported-nginx --rm --publish 8080:80 nginx-saved-container

   > curl localhost:8080
   This container image was saved from a running nginx container
   ```

4. The file [Containers-Import-Image-From-tar.nginx-exported-container.tar.xz](https://github.com/mmul-it/training/raw/master/Kubernetes-From-Scratch/Containers-Import-Image-From-tar.nginx-exported-container.tar.xz)
   should be downloaded and uncompressed:

   ```console
   > curl -sL https://github.com/mmul-it/training/raw/master/Kubernetes-From-Scratch/Containers-Import-Image-From-tar.nginx-exported-container.tar.xz -o Containers-Import-Image-From-tar.nginx-exported-container.tar.xz

   > xz -d Containers-Import-Image-From-tar.nginx-exported-container.tar.xz
   ```

5. The `docker load` command should end up in an error:

   ```console
   > docker load -i Containers-Import-Image-From-tar.nginx-exported-container.tar
   open /var/lib/docker/tmp/docker-import-876757938/bin/json: no such file or directory
   ```

6. On the other side `docker import` should work as expoected:

   ```console
   > docker import Containers-Import-Image-From-tar.nginx-exported-container.tar
   sha256:14d03acca58c313b665d9cc9f283147239b1b8b7bb25fc731b674dffa01d07d8
   ```

   To use this image take note of the first 12 chars of the image id on the
   previous output (in this case `14d03acca58`), and tag the image as
   `nginx-exported-container`.

7. But the problem is now `docker run`, that will not work:

   ```console
   > docker run --detach --name nginx-exported-container --rm --publish 8080:80 nginx-exported-container
   docker: Error response from daemon: No command specified.
   See 'docker run --help'.
   ```

   The export that was originally made on this image do not contain any metadata
   useful to docker to run the base container, because of this `docker run`
   fails.
