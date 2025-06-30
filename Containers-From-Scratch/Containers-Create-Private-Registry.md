# Lab | Containers Create Private Registry

1. Pull the image `registry` from the docker registry.
2. Create a local directory named `registry` that will be the registry storage.
3. Run the container in detach mode, mapping the local directory `registry` to
   the `/var/lib/registry` path in the container, and publishing the container's
   port `5000` to the localhost port `5000`. Apply the `always` restart policy
   and name the container `registry`.
4. Check the contents of the local `registry` directory, is it empty?
5. Pull the `nginx:latest` image and tag the image so that it could be pushed
   into the newly created registry.
6. Push the image and verify that the remote registry now contains the image.
7. Stop the `registry` container.

## Solution

1. Use `docker pull` to get the image:

   ```console
   $ docker pull registry
   Using default tag: latest
   latest: Pulling from library/registry
   ef5531b6e74e: Pull complete
   a52704366974: Pull complete
   dda5a8ba6f46: Pull complete
   eb9a2e8a8f76: Pull complete
   25bb6825962e: Pull complete
   Digest: sha256:3f71055ad7c41728e381190fee5c4cf9b8f7725839dcf5c0fe3e5e20dc5db1fa
   Status: Downloaded newer image for registry:latest
   docker.io/library/registry:latest
   ```

2. Create the local directory with `mkdir`:

   ```console
   $ mkdir -v $PWD/registry
   mkdir: created directory '/home/kirater/registry'
   ```

   In case you're running CentOS with SELinux enabled:

   ```console
   $ chcon -R -t container_file_t $PWD/registry
   (no output)
   ```

3. Run the container using `--publish` to map the port, `--volume` to map the
   local directory, and `--rm` to remove the container after it will be stopped:

   ```console
   $ docker run --detach --publish 5000:5000 \
       --name registry --rm \
       --volume $PWD/registry:/var/lib/registry registry
   28c991c8bf63a5df758c40e04314a4e836d232735b6b19d713038fb77762054b
   ```

4. Use `find` to check the folder:

   ```console
   $ find $PWD/registry
   registry/
   ```

   Yes, it is empty.

5. Now use `docker pull` to get `nginx:latest` and `docker tag` to tag it to the
   local registry:

   ```console
   $ docker pull nginx:latest
   latest: Pulling from library/nginx
   bb263680fed1: Pull complete
   258f176fd226: Pull complete
   a0bc35e70773: Pull complete
   077b9569ff86: Pull complete
   3082a16f3b61: Pull complete
   7e9b29976cce: Pull complete
   Digest: sha256:a77d5b5283a97f86a278b46a66821a8d24788a2963404d51953ed43f5c4f61f3
   Status: Downloaded newer image for nginx:latest
   docker.io/library/nginx:latest

   $ docker tag nginx:latest localhost:5000/nginx:latest
   (no output)
   ```

6. Use `docker push` to push the image into the registry:

   ```console
   $ docker push localhost:5000/nginx:latest
   The push refers to repository [localhost:5000/nginx]
   3ea1bc01cbfe: Pushed
   a76121a5b9fd: Pushed
   2df186f5be5c: Pushed
   21a95e83c568: Pushed
   81e05d8cedf6: Pushed
   4695cdfb426a: Pushed
   latest: digest: sha256:7f797701ded5055676d656f11071f84e2888548a2e7ed12a4977c28ef6114b17 size: 1570
   ```

   Now it should be possible to verify its contents using one of the various
   ways to check a registry:

   ```console
   $ find $PWD/registry
   /home/kirater/registry
   /home/kirater/registry/docker
   /home/kirater/registry/docker/registry
   /home/kirater/registry/docker/registry/v2
   /home/kirater/registry/docker/registry/v2/blobs
   /home/kirater/registry/docker/registry/v2/blobs/sha256
   ...
   ...
   /home/kirater/registry/docker/registry/v2/repositories/nginx
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/revisions
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/revisions/sha256
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/revisions/sha256/7f797701ded5055676d656f11071f84e2888548a2e7ed12a4977c28ef6114b17
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/revisions/sha256/7f797701ded5055676d656f11071f84e2888548a2e7ed12a4977c28ef6114b17/link
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/tags
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/tags/latest
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/tags/latest/index
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_manifests/tags/latest/index/sha256
   ...
   ...
   /home/kirater/registry/docker/registry/v2/repositories/nginx/_uploads

   $ curl -s http://localhost:5000/v2/_catalog | jq
   {
     "repositories": [
       "nginx"
     ]
   }

   $ curl -s http://localhost:5000/v2/nginx/tags/list | jq
   {
     "name": "nginx",
     "tags": [
       "latest"
     ]
   }

   $ docker run --rm \
       --network host \
       anoxis/registry-cli -r http://localhost:5000 -i nginx
   ---------------------------------
   Image: nginx
     tag: latest
   ```

7. Stopping the `registry` container it will be automatically removed (because of the `--rm` used in the `docker run` command):

   ```console
   $ docker stop registry
   registry
   ```
