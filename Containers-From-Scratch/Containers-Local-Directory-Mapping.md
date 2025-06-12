# Lab | Containers Local Directory Mapping

In this lab you will:

1. Create a folder on your homedir named `local-dir` and enable the correct
   SELinux context for the directory if you are on CentOS/Red Hat.
2. Run a nginx container image named `local-dir-mapping-test`, exposing on
   localhost the 8080 port mapping also the newly created volume into the
   container directory `/usr/share/nginx/html`.
3. Check the status of the `local-dir` on the host, what has changed?
4. Create in local-dir a file named `index.html` containing "Local dir test"
   text and verify that the web page now displays it accordingly.
5. Stop the container.
6. Start a new container with the name "local-dir-mapping-test-relaunch" and the
   mapping of the local directory and check that the page still shows our
   modified message despite the fact that the container was created again from
   scratch.
7. Stop the `local-dir-mapping-test`.

## Solution

1. Create a local directory:

   ```console
   $ mkdir local-dir
   (no output)
   ```

   Do not forget to assign the correct SELinux context on the directory, if you
   are on a CentOS/Red Hat system:

   ```console
   $ chcon -R -t container_file_t local-dir
   (no output)
   ```

2. Launch the container mapping the directory with `--volume`:

   ```console
   $ docker run --detach --name local-dir-mapping-test --rm \
       --publish 8080:80 \
       --volume $PWD/local-dir:/usr/share/nginx/html \
       nginx
   5d06d232e6e134d7713265221b81eed4ba7e91a848113286d9400d5164252f64
   ```

3. Nothing. It is still empty, and it's a different behavior from volume. In
   fact:

   ```console
   $ curl localhost:8080
   <html>
   <head><title>403 Forbidden</title></head>
   <body>
   <center><h1>403 Forbidden</h1></center>
   <hr><center>nginx/1.23.2</center>
   </body>
   </html>
   ```

4. Create a file named `index.html` inside the `local-dir` and check again via
   `curl`:

   ```console
   $ echo "Local dir test" > local-dir/index.html
   $ curl localhost:8080
   Local dir test
   ```

5. Stop the container:

   ```console
   $ docker stop local-dir-mapping-test
   local-dir-mapping-test
   ```

6. Relaunch the container and check again via curl to confirm persistency:

   ```console
   $ docker run --detach --name local-dir-mapping-test-relaunch --rm \
       --publish 8080:80 \
       --volume $PWD/local-dir:/usr/share/nginx/html \
       nginx
   a81076af88c696c9b1dd4c763feea90fc1eda9c76a262a56daf7bcfd2b5390ca

   $ curl localhost:8080
   Local dir test
   ```

7. Stop the `local-dir-mapping-test`.

   ```console
   $ docker stop local-dir-mapping-test
   local-dir-mapping-test
   ```
