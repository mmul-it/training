# Exercise | Containers Local Directory Mapping

1) Create a folder on your homedir named "local-dir" and enable the correct SELinux context for the directory if you are on CentOS/Red Hat.

2) Run a nginx container image named "local-dir-mapping-test", exposing on localhost the 8080 port mapping also the newly created volume into the container directory /usr/share/nginx/html.

3) Check the status of the local-dir on the host, what is changed?

4) Create in local-dir a file named index.html containing "Local dir test" text and verify that the web page now answers accordingly.

5) Stop the container.

6) Start a new container with the name "local-dir-mapping-test-relaunch" and the mapping of the local directory and check that the page still shows our modified message despite from the fact that the container was created again from scratch.
