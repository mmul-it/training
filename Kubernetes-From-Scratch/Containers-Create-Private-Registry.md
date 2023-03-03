# Exercise | Containers Create Private Registry

1. Pull the image `registry` from the docker registry.

2. Create a local directory named `registry` that will be the registry storage.

3. Run in detach mode the container so that will map the local directory
   `registry` to the `/var/lib/registry` and will publish the container port
   `5000` to the localhost port `5000`.

   Apply the restart policy `always` and name it `registry`;

4. Check the contents of the local `registry` directory, is it empty?

5. Pull the `nginx:latest` image and tag the image so that it could be pushed
   into the newly created registry.

6. Push the image and verify that the remote registry now contains the image.
