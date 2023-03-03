# Exercise | Containers Build Custom Image | Solution

1. Create the folder dedicated to the container build:

   ```console
   > mkdir mycontainer && cd mycontainer
   ```

2. The `Dockerfile` file should have this contents:

   ```Dockerfile
   FROM alpine:latest

   ENV NCAT_MESSAGE "Container test"
   ENV NCAT_HEADER "HTTP/1.1 200 OK"
   ENV NCAT_PORT "8888"

   RUN apk add bash nmap-ncat

   CMD /usr/bin/ncat -l $NCAT_PORT -k -c "echo '$NCAT_HEADER'; echo; echo $NCAT_MESSAGE"

   EXPOSE $NCAT_PORT
   ```

   There's a [downloadable copy](https://github.com/mmul-it/training/raw/master/Kubernetes-From-Scratch/Containers-Build-Custom-Image.Dockerfile)
   available on this repository.

3. Now it's time to use `docker build`:

   ```console
   > docker build -t myfirstapp:v1 .
   [+] Building 5.5s (6/6) FINISHED                                                                                         
    => [internal] load build definition from Dockerfile                                                                0.1s
    => => transferring dockerfile: 377B                                                                                0.0s
    => [internal] load .dockerignore                                                                                   0.1s
    => => transferring context: 2B                                                                                     0.0s
    => [internal] load metadata for docker.io/library/alpine:latest                                                    1.8s
    => [1/2] FROM docker.io/library/alpine:latest@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0ef  1.5s
    => => resolve docker.io/library/alpine:latest@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0ef  0.1s
    => => sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a 1.64kB / 1.64kB                      0.0s
    => => sha256:e2e16842c9b54d985bf1ef9242a313f36b856181f188de21313820e177002501 528B / 528B                          0.0s
    => => sha256:b2aa39c304c27b96c1fef0c06bee651ac9241d49c4fe34381cab8453f9a89c7d 1.47kB / 1.47kB                      0.0s
    => => sha256:63b65145d645c1250c391b2d16ebe53b3747c295ca8ba2fcb6b0cf064a4dc21c 3.37MB / 3.37MB                      1.1s
    => => extracting sha256:63b65145d645c1250c391b2d16ebe53b3747c295ca8ba2fcb6b0cf064a4dc21c                           0.2s
    => [2/2] RUN apk add bash nmap-ncat                                                                                1.9s
    => exporting to image                                                                                              0.2s 
    => => exporting layers                                                                                             0.2s 
    => => writing image sha256:cbeeaefd6bbcc8c42855a574d33b89fbde4c49d8bbc86c4201174b66db23f691                        0.0s 
    => => naming to docker.io/library/myfirstapp:v1                                                                    0.0s
   ```

4. And launch it:

   ```console
   > docker run --rm --detach --name myfirstapp --publish 8888:8888 myfirstapp:v1
   27555f50a085358f2e22d6adb35591016c540fb744184254aa1e94839b8bf31b
   ```

5. To check the output use `curl`:

   ```console
   > curl localhost:8888
   Container test
   ```
