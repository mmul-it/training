# Lab | Containers Monitor Networking

In this lab you will:

1. Pull and run the `mysql` container image with the name `network-test`, exposing the 3306 port to the 3306 on the host.
2. Obtain the PID of the container process on the host.
3. Use the `nsenter` command (to execute a command in another namespace) on this PID so that you can launch a `tcpdump` (to be installed) on the container's network interface.
4. From another console, connect to the exposed port and generate some traffic, monitoring what happens on the `tcpdump`.
5. Stop the `network-test` container.

## Solution

1. Use `docker run` to start MySQL container, passing the `MYSQL_ROOT_PASSWORD` environment variable:

   ```console
   $ docker run --rm --detach --name network-test -p 3306:3306 -e MYSQL_ROOT_PASSWORD=testr00t mysql
   Unable to find image 'mysql:latest' locally
   latest: Pulling from library/mysql
   996f1bba14d6: Pull complete
   a4355e2c82df: Pull complete
   a9d7aedb7ad7: Pull complete
   24ee75d8667d: Pull complete
   da8c1ec8ff26: Pull complete
   ea8748759282: Pull complete
   e0859d5816ee: Pull complete
   26e144df551b: Pull complete
   9878df6a0cc3: Pull complete
   b43b187428e3: Pull complete
   202e454031c6: Pull complete
   Digest: sha256:66efaaa129f12b1c5871508bc8481a9b28c5b388d74ac5d2a6fc314359bbef91
   Status: Downloaded newer image for mysql:latest
   47d40addd8d0475685c8147b2937e47242615f38ab4b2de48387edcfe0ecfdaf
   ```

2. There are two methods to find out the PID, one is via the `ps` command:

   ```console
   $ ps -ef | grep [m]ysql
   999       **290813**  290792  1 15:42 ?        00:00:01 mysqld
   ```

   The other one is via `docker inspect`:

   ``` console
   $ docker inspect --format {{.State.Pid}} network-test
   **290813**
   ```

3. Install `tcpdump`, using for Debian based systems:

   ```console
   $ sudo apt-get update
   ...
   $ sudo apt-get install -y tcpdump
   ...
   ```

   And for RHEL based systems:

   ```console
   $ sudo yum update
   ...
   $ sudo yum -y install tcpdump
   ...
   ```

   And execute `nsenter`:

   $ sudo nsenter -t 290813 -n tcpdump -i eth0 -vvv
   tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
   ```

4. From another console use `nc` to reach the 3306 port:

   ```console
   $ nc -v localhost 3306
   Connection to localhost 3306 port [tcp/mysql] succeeded!
   J
   8.0.31
       3b\X&�����f1vnqG.a<LBcaching_sha2_password
   ```

   On the other console you should see the traffic:

   ```console
   15:50:51.239341 IP (tos 0x0, ttl 64, id 4852, offset 0, flags [DF], proto TCP (6), length 60)
       172.17.0.1.43986 > 172.17.0.3.mysql: Flags [S], cksum 0x5855 (incorrect -> 0xc68d), seq 2677253658, win 64240, options [mss 1460,sackOK,TS val 580324697 ecr 0,nop,wscale 7], length 0
   15:50:51.239357 ARP, Ethernet (len 6), IPv4 (len 4), Request who-has 172.17.0.1 tell 172.17.0.3, length 28
   15:50:51.239369 ARP, Ethernet (len 6), IPv4 (len 4), Reply 172.17.0.1 is-at 02:42:c5:d9:57:18 (oui Unknown), length 28
   15:50:51.239373 IP (tos 0x0, ttl 64, id 0, offset 0, flags [DF], proto TCP (6), length 60)
       172.17.0.3.mysql > 172.17.0.1.43986: Flags [S.], cksum 0x5855 (incorrect -> 0x1449), seq 2930249925, ack 2677253659, win 65160, options [mss 1460,sackOK,TS val 311024804 ecr 580324697,nop,wscale 7], length 0
   ...
   ...
   ```

5. Stop the `network-test` container:

   ```console
   $ docker stop network-test
   network-test
   ```

---

## Alternative method to get access to the network namespace

Create the namespace directory `/var/run/netns` and link the system namespace associated with the process (`/proc/<PID>/ns/net`) with the container ID (`/var/run/netns/<containerID>`):

```console
$ sudo mkdir /var/run/netns
(no output)

$ sudo ln -s /proc/290813/ns/net /var/run/netns/network-test
(no output)
```

The namespace should become visible via `ip netns show`, and in addition it should be possible to exec commands within it.

Execute `tcpdump` on this namespace so that you will be able to see all the traffic passing by `eth0`:

```console
$ sudo ip netns exec network-test tcpdump -i eth0 -vvv
...
```
