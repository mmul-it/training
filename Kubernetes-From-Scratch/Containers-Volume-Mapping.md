# Exercise | Containers Volume Mapping

1. Create an empty volume named "test-volume".

2. Check the contents of the newly created volume on the filesystem. Where it will be placed?

3. Run a nginx container image named "volume-mapping-test", exposing on localhost the 8080 port mapping also the newly created volume into the container directory /usr/share/nginx/html.

4. Check again the status of the volume on the host, what is changed?

5. Change the content of the index.html to be just "Volume test" and verify that on the web page now answers with the new text.

6. Stop the container.

7. Check again the status of the volume on the host.

8. Start a new container with the name "volume-mapping-test-relaunch" and the mapping of the previous volume and check that the page still shows our modified message despite from the fact that the container was created again from scratch.
