# Lab | Containers Host Networking

In this lab you will:

1. Pull and run the `nginx` container image with the name `network-host-test`
   using the host networking.
2. Check that the service will be reachable on localhost on the port exposed by
   the container.
3. Stop the `network-host-test` container.
4. Run the `nginx` container image with the name `network-host-test` using the
   host networking and publishing the container 80 port to the 8888 port on the
   host.
5. Is it possible? What happens?
6. Stop the `network-host-test` container.

## Solution

1. Launch the container with the `--network host` option:

   ``` console
   $ docker run --detach --name network-host-test --rm \
       --network host \
       nginx
   5ef2cfd4d6aff9d675a299ef9100d0e00e79383dae8cccac4f144e003673b457
   ```

2. Use `curl` to check the port:

   ``` console
   $ curl -s http://localhost | grep Welcome
   <title>Welcome to nginx!</title>
   <h1>Welcome to nginx!</h1>
   ```

3. Stop the container:

   ``` console
   $ docker stop network-host-test
   network-host-test
   ```

4. Use both `--network host` and `-p 8888:80` to check whether it is possible to
   publish the port:

   ``` console
   $ docker run --detach --name network-host-test --rm \
       --network host \
       --publish 8888:80 \
       nginx
   WARNING: Published ports are discarded when using host network mode
   e5c600cf3eab15ef23cb6b79870d7bba8ac4a2fabda7ae7e2a8ba24fbddd5925
   ```

5. Since the result is:

   ``` console
   WARNING: Published ports are discarded when using host network mode
   bb499f166a75865d0617c322e78f90724e857b1f404976a3c4a19f946347ba03
   ```

   the publication of ports while using the host mode is impossible, there's a
   WARNING and it is just ignored.

6. Stop the `network-host-test` container:

   ```console
   $ docker stop network-host-test
   network-host-test
   ```
