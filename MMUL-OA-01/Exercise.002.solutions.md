# Exercise 002 - Running your first container on crc - Solutions

---

1. Use crc executable to load the podman environment:

   ```console
   > eval $(crc podman-env)
   ```

2. Use the podman-remote command as it was the local podman command:

   ```console
   > podman-remote run --rm --detach --publish 8888:80 --name first-nginx-test alpine_nginx
   fb7b7baf561d4ca28fd22e5ee8531876adfe2945596cb7872eeca87cb6fcdb2e
   ```

3. Use the ```crc ip``` command with curl to verify the status of the port:

   ```console
   > curl $(crc ip):8888
   podman rulez
   ```

4. Since we launched the command with --rm option, then it is sufficient to
   stop it and it will be automatically destroyed:

   ```console
   > podman-remote stop first-nginx-test

   > podman-remote ps -a
   CONTAINER ID  IMAGE   COMMAND  CREATED  STATUS  PORTS   NAMES
   ```

   **IMPORTANT NOTE!** there's a bug that prevents podman-remote to get always
   the expected output, causing sometimes output like this:

   ```console
   [crc@CentOS-83-64-minimal ~]$ podman-remote ps
   CONTAINER ID  IMAGE   COMMAND  CREATED  STATUS  PORTS   NAMES

   [crc@CentOS-83-64-minimal ~]$ podman-remote ps
   Error: Get "http://d/v2.0.0/libpod/_ping": EOF

   [crc@CentOS-83-64-minimal ~]$ podman-remote ps
   Error: Get "http://d/v2.0.0/libpod/_ping": EOF

   [crc@CentOS-83-64-minimal ~]$ podman-remote ps
   CONTAINER ID  IMAGE   COMMAND  CREATED  STATUS  PORTS   NAMES

   [crc@CentOS-83-64-minimal ~]$ podman-remote ps
   Error: Get "http://d/v2.0.0/libpod/_ping": EOF
   ```

   So it might be that this exercise will fail until this bug
   https://github.com/code-ready/crc/issues/2609 gets solved.
