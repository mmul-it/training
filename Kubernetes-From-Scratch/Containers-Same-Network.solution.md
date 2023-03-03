# Exercise | Containers Same Network | Solution

1. Run the two containers simoultanously in two differen terminals:

   ```console
   docker run --name=container1 --rm -it alpine /bin/sh
   / #

   > docker run --name=container2 --rm -it alpine /bin/sh
   / #
   ```

2. Try the ping:

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
   > docker network create test --subnet "172.16.99.0/24"
   1cb5ca8888a1b4f577bd1bcbb1babb72015b816d031015b1a6f5a07613d58dc2
   ```

5. Re-run the two containers:

   ```console
   > docker run --name=container1 --network=test --rm -it alpine /bin/sh
   / #

   > docker run --name=container2 --network=test --rm -it alpine /bin/sh
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

7. On `container1` use `nc -v -l -p 8888` to listen on tcp port `8888`:

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
   > docker network remove test
   test
   ```
