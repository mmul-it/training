# Lab | Containers Volume Mapping

In this lab you will:

1. Create an empty volume named `test-volume`.
2. Check the contents of the newly created volume on the filesystem. Where it will be placed?
3. Run a nginx container image named `volume-mapping-test`, exposing on localhost the 8080 port and also mapping the newly created volume into the container directory `/usr/share/nginx/html`.
4. Check again the status of the volume on the host. What has changed?
5. Change the content of the index.html to be just "Volume test" and verify that the web page now displays the new text.
6. Stop the container.
7. Check again the status of the volume on the host.
8. Start a new container with the name `volume-mapping-test-relaunch` mapping the previous volume, and check that the page still shows our modified message despite the fact that the container was created again from scratch.
9. Stop the `volume-mapping-test-relaunch` container.

## Solution

1. Use `docker volume` command to create a volume:

   ```console
   $ docker volume create test-volume
   test-volume
   ```

2. Look into the `/var/lib/docker/volumes` path:

   ```console
   $ sudo find /var/lib/docker/volumes/test-volume -ls
    12986865      4 drwx-----x   3 root     root         4096 Dec  2 14:58 /var/lib/docker/volumes/test-volume
    12986866      4 drwxr-xr-x   2 root     root         4096 Dec  2 14:58 /var/lib/docker/volumes/test-volume/_data
   ```

3. Execute the container with the `-v` option:

   ```console
   $ docker run -d --name volume-mapping-test --rm --publish 8080:80 --volume test-volume:/usr/share/nginx/html nginx
   f19f9e23f86468c0e5051d4e1652535b4b7e8dad708a823dc63695bd576f42f5
   ```

4. There are new files:

   ```console
   $ sudo find /var/lib/docker/volumes/test-volume -ls
    12986865      4 drwx-----x   3 root     root         4096 Dec  2 14:58 /var/lib/docker/volumes/test-volume
    12986866      4 drwxr-xr-x   2 root     root         4096 Dec  2 14:58 /var/lib/docker/volumes/test-volume/_data
    12986869      4 -rw-r--r--   1 root     root          497 Oct 19 07:56 /var/lib/docker/volumes/test-volume/_data/50x.html
    12986870      4 -rw-r--r--   1 root     root          615 Oct 19 07:56 /var/lib/docker/volumes/test-volume/_data/index.html
   ```

5. Log into the container and change the `index.html` content:

   ```console
   $ docker exec -it volume-mapping-test /bin/bash
   root@f19f9e23f864:/# echo "Volume test" > /usr/share/nginx/html/index.html
   root@f19f9e23f864:/# exit
   exit

   $ curl localhost:8080
   Volume test
   ```

6. Stop the container:

   ```console
   $ docker stop volume-mapping-test
   volume-mapping-test
   ```

7. Files are still there:

   ```console
   $ sudo find /var/lib/docker/volumes/test-volume -ls
    12986865      4 drwx-----x   3 root     root         4096 Dec  2 14:58 /var/lib/docker/volumes/test-volume
    12986866      4 drwxr-xr-x   2 root     root         4096 Dec  2 14:58 /var/lib/docker/volumes/test-volume/_data
    12986869      4 -rw-r--r--   1 root     root          497 Oct 19 07:56 /var/lib/docker/volumes/test-volume/_data/50x.html
    12986870      4 -rw-r--r--   1 root     root           12 Dec  2 14:59 /var/lib/docker/volumes/test-volume/_data/index.html
   ```

8. The volume is persistent:

   ```console
   $ docker run -d --name volume-mapping-test-relaunch --rm --publish 8080:80 --volume test-volume:/usr/share/nginx/html nginx
   6499fd8c64cf97844edcb10b165b303776dc59ed32bb633336ac75c6db6f2185

   $ curl localhost:8080
   Volume test
   ```

9. Stop the `volume-mapping-test-relaunch` container:

   ```console
   $ docker stop volume-mapping-test-relaunch
   volume-mapping-test-relaunch
   ```
