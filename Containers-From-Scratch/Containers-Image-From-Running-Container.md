# Lab | Containers Image From Running Image

In this lab you will:

1. Run a container named `nginx` using the `nginx:alpine` image.
2. Log into the container `nginx`.
3. Change the contents of the `index.html` default file exposed by the nginx
   instance to be `My new shiny Nginx container image`, you can find out where
   the default file is stored by looking into the
   `/etc/nginx/conf.d/default.conf` config file.
4. Exit the container console and generate an image starting from this running
   instance, calling it `my-new-shiny-nginx`.
5. Stop the original container.
6. Create a new container starting from the newly created image, and check that
   the modifications made are available.
7. Stop the `my-new-shiny-nginx` container.

## Solution

1. Launch the container using `docker run`:

   ```console
   $ docker run --detach --name nginx --rm \
       --publish 8888:80 \
       nginx:alpine
   791f3dd1b349e36991b8400ac10c1d657ac143c7d1b353e8f69f581c35cd033f
   ```

2. Start an interactive shell on the running container using `docker exec`:

   ```console
   $ docker exec --interactive --tty nginx /bin/sh
   / #
   ```

3. Check with `grep` what is the value of `root` in
   `/etc/nginx/conf.d/default.conf`:

   ```console
   / # grep root /etc/nginx/conf.d/default.conf
           root   /usr/share/nginx/html;
           root   /usr/share/nginx/html;
       #    root           html;
       # deny access to .htaccess files, if Apache's document root
   ```

   So the file to be modified will be `/usr/share/nginx/html/index.html`, in
   this way:

   ```console
   / # echo 'My new shiny Nginx container image' > /usr/share/nginx/html/index.html
   / # exit
   ```

4. After verifying the running container is returning the output, use
   `docker commit` to create a new version of the container:

   ```console
   $ curl localhost:8888
   My new shiny Nginx container image

   $ docker commit nginx my-new-shiny-nginx
   sha256:657bed3e775b2c62e1801c72fdb818144a2b231242a78ff9311288e0bad5765
   ```

5. Stop the container:

   ```console
   $ docker stop nginx
   nginx
   ```

6. Use the new image to launch the container as before and verify the
   output:

   ```console
   $ docker run --detach --name my-new-shiny-nginx --rm \
       --publish 8888:80 \
       my-new-shiny-nginx
   eee76f1d96d305bbf3e71a1a6a6be9019cf7929f685aaa2da26d0f3aab749b7a

   $ curl localhost:8888
   My new shiny Nginx container image
   ```

7. Stop the `my-new-shiny-nginx` container:

   ```console
   $ docker stop my-new-shiny-nginx
   my-new-shiny-nginx
   ```
