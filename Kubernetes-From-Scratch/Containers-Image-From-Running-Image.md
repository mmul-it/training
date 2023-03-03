# Exercise | Containers Image From Running Image

1. Run a container named `nginx` using the `nginx:alpine` image.

2. Log into the container`

3. Change the contents of the `index.html` default file exposed by the nginx
   instance to be `My new shiny Nginx container image`, you can find out where
   the default file is stored by looking into the
   `/etc/nginx/conf.d/default.conf` config file.

4. Exit the container console and generate an image starting from this running
   instance, called `my-new-shiny-nginx`.

5. Stop the original container.

6. Create a new container starting from the newly created image, and check that
   the modifications made are available.
