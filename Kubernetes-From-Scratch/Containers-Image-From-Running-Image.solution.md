# Exercise | Containers Image From Running Image | Solution

1. Launch the container using `docker run`:

   ```console
   > docker run --detach --name nginx --rm -p 8888:80 nginx:alpine
   ```

2. Start an interactive shell on the running container using `docker exec`:

   ```console
   > docker exec -it nginx /bin/sh
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
   > curl localhost:8888
   My new shiny Nginx container image

   > docker commit nginx my-new-shiny-nginx
   sha256:657bed3e775b2c62e1801c72fdb818144a2b231242a78ff9311288e0bad5765
   ```

5. Stop the container:

   ```console
   > docker stop nginx
   nginx
   ```

6. Use the new image to launch the container the same as before and verify the
   output:

   ```console
   > docker run --detach --name nginx --rm --publish 8888:80 my-new-shiny-nginx

   > curl localhost:8888
   My new shiny Nginx container image
   ```
