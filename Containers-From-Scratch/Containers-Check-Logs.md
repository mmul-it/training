# Lab | Containers Check Logs

In this lab you will:

1. Run from www.mmul.it, at port 5000, the `broken-nginx` image exposing the
   `8080` port locally.
   Authenticate yourself with user "dockertraining" and password "l3tstr41n".
2. Check if the container is running (it should not).
3. Try to find out what's wrong with this image.
4. Fix the problem on this image and create a new and usable one.
5. Stop and remove the newly created running container.

## Solution

1. Authenticate over the remote registry:

   ```console
   $ docker login -u dockertraining www.mmul.it:5000
   Password:
   WARNING! Your password will be stored unencrypted in /home/rasca/.docker/config.json.
   Configure a credential helper to remove this warning. See
   https://docs.docker.com/engine/reference/commandline/login/#credentials-store

   Login Succeeded
   ```

   Run the container by using the `--log-driver journald` option:

   ```console
   $ docker run --detach --name broken-nginx \
        --publish 8080:80 \
        --log-driver journald \
        www.mmul.it:5000/broken-nginx
   Unable to find image 'www.mmul.it:5000/broken-nginx:latest' locally
   latest: Pulling from broken-nginx
   63b65145d645: Already exists
   8c7e1fd96380: Already exists
   86c5246c96db: Already exists
   b874033c43fb: Already exists
   dbe1551bd73f: Already exists
   0d4f6b3f3de6: Already exists
   2a41f256c40f: Already exists
   f6177051e087: Pull complete
   Digest: sha256:9c9e2a90caf3c87efa8c4b675424e2cec1013863af1cab4d532fc3690f09ec0b
   Status: Downloaded newer image for www.mmul.it:5000/broken-nginx:latest
   18a47a37fc7406239c5eec55282dda1f3e89ace376a6835ead1850097ea64caf
   ```

2. Check *all* the containers:

   ```console
   $  docker ps -a
   CONTAINER ID   IMAGE                                 COMMAND                  CREATED              STATUS                         PORTS  NAMES
   b8bb369cf740   www.mmul.it:5000/broken-nginx         "/docker-entrypoint.…"   About a minute ago   Exited (1) About a minute ago         broken-nginx
   ```

3. You can now check the logs in two ways, the usual one:

   ```console
   $ docker logs broken-nginx
   /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
   /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
   10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
   10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
   /docker-entrypoint.sh: Configuration complete; ready for start up
   2023/03/02 18:00:14 [emerg] 1#1: open() "/etc/nginx/nginx.conf" failed (2: No such file or directory)
   nginx: [emerg] open() "/etc/nginx/nginx.conf" failed (2: No such file or directory)
   ```

   or by using `journalctl`:

   ```console
   $ journalctl CONTAINER_NAME=broken-nginx
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: 10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: 10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: /docker-entrypoint.sh: Configuration complete; ready for start up
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: 2023/03/02 18:05:29 [emerg] 1#1: open() "/etc/nginx/nginx.conf" failed (2: No such file or directory)
   mar 02 19:05:29 ubuntu-jammy b8bb369cf740[856]: nginx: [emerg] open() "/etc/nginx/nginx.conf" failed (2: No such file or directory)
   ```

   So there seems to be no `/etc/nginx/nginx.conf` in the image, which is a
   mandatory file for nginx.

4. Once removed the failed container:

   ```console
   $ docker rm broken-nginx
   broken-nginx
   ```

   It will be possible to start the container overriding the default command,
   opening an interactive shell and looking inside the `/etc/nginx/` to see if
   there are clues about something:

   ```console
   $ docker run -it --rm --name broken-nginx \
        --publish 8080:80 \
        --log-driver journald \
        www.mmul.it:5000/broken-nginx /bin/sh
   / # ls -1 /etc/nginx/
   conf.d
   fastcgi.conf
   fastcgi_params
   mime.types
   modules
   nginx.conf.FIXME
   scgi_params
   uwsgi_params
   ```

   So by renaming the `nginx.conf.FIXME` file into `nginx.conf` the contents of
   *this* container will be fine:

   ```console
   / # mv /etc/nginx/nginx.conf.FIXME /etc/nginx/nginx.conf
   ```

   Now, from another shell, we can take the running image and `commit` it into a
   new one, remembering to override the command `CMD`, since we used `/bin/sh`
   as default, which is not what we want for nginx.
   The option will be `--change='CMD ["nginx", "-g", "daemon off;"]'`:

   ```console
   $ docker commit --change='CMD ["nginx", "-g", "daemon off;"]' broken-nginx fixed-nginx
   sha256:71a64377a3a63b13013b070f808a41f206d2a36335ff5729c9d551c04b871eab
   ```

   It will be finally possible to exit from the original container:

   ```console
   # / exit
   ```

   And launch the new `fixed-nginx` image:

   ```console
   $ docker run --detach --name fixed-nginx \
        --publish 8080:80 \
        --log-driver journald \
        fixed-nginx
   d72b13a9118355b95e0e061c9e98b31458df22fb49a335d8376dfa50b25d79a9

   $ curl localhost:8080
   <!DOCTYPE html>
   <html>
   <head>
   <title>Welcome to nginx!</title>
   <style>
   html { color-scheme: light dark; }
   body { width: 35em; margin: 0 auto;
   font-family: Tahoma, Verdana, Arial, sans-serif; }
   </style>
   </head>
   <body>
   <h1>Welcome to nginx!</h1>
   <p>If you see this page, the nginx web server is successfully installed and
   working. Further configuration is required.</p>

   <p>For online documentation and support please refer to
   <a href="http://nginx.org/">nginx.org</a>.<br/>
   Commercial support is available at
   <a href="http://nginx.com/">nginx.com</a>.</p>

   <p><em>Thank you for using nginx.</em></p>
   </body>
   </html>
   ```

   The result is the default NGINX page, which is correct.

5. We didn't launch the container with the `--rm` option, so stop and remove the fixed-nginx container:

   ```console
   $ docker stop fixed-nginx
   fixed-nginx
   $ docker rm fixed-nginx
   fixed-nginx
   ```
