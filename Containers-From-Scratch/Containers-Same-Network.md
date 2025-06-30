# Lab | Containers Same Network

In this lab you will:

1. In two different shells, create two interactive containers named
   "container1" and "container2" from the image `alpine:latest`.
2. From "container1" try to ping "container2" and see if it works.
3. Stop and remove the containers.
4. Create a custom network named "test" with the subnet "172.16.99.0/24".
5. In two different shells, create two interactive containers named
   "container1" and "container2" from the image alpine:latest that
   make use of the newly created "test" network.
6. From "container1" try to ping "container2" and see if it works.
7. Listen on the 8888 port on "container1" and try to reach it from
   "container2" to check if everything works.
8. Cleanup everything.

## Solution

1. Run the two containers simoultanously in two differen terminals:

   ```console
   $ docker run --name=container1 --rm --interactive --tty alpine /bin/sh
   / #

   $ docker run --name=container2 --rm --interactive --tty alpine /bin/sh
   / #
   ```

2. Try to ping `container2` from `container1`:

   ```console
   / # ping container2
   ping: bad address 'container2'
   ```

3. On each container's shell:

   ```console
   / # exit
   ```

4. Using `docker network create` create the `test` subnet:

   ```console
   $ docker network create test --subnet "172.16.99.0/24"
   1cb5ca8888a1b4f577bd1bcbb1babb72015b816d031015b1a6f5a07613d58dc2
   ```

5. Re-run the two containers:

   ```console
   $ docker run --name=container1 --rm --interactive --tty \
       --network=test \
       alpine /bin/sh
   / #

   $ docker run --name=container2 --rm --interactive --tty \
       --network=test \
       alpine /bin/sh
   / #
   ```

6. On `container1`:

   ```console
   / # ping -c2 container2
   PING container2 (172.16.99.2): 56 data bytes
   64 bytes from 172.16.99.2: seq=0 ttl=64 time=0.119 ms
   64 bytes from 172.16.99.2: seq=1 ttl=64 time=0.136 ms

   --- container2 ping statistics ---
   2 packets transmitted, 2 packets received, 0% packet loss
   round-trip min/avg/max = 0.070/0.077/0.085 ms
   ```

7. On `container1` use `nc -v -l -p 8888` to listen on TCP port `8888`:

   ```console
   / # nc -v -l -p 8888
   listening on [::]:8888 ...
   ```

   And from `container2` verify that the port is reachable:

   ```console
   / # nc -v container1 8888
   container1 (172.16.99.3:8888. open
   TEST
   ```

   On `container1` you should see:

   ```console
   connect to [::ffff:172.16.99.3]:8888 from container2.test:37453 ([::ffff:172.16.99.2]:37453)
   TEST
   ```

8. On each container's shell:

   ```console
   / # exit
   ```

   On the host:

   ```console
   $ docker network remove test
   test
   ```
