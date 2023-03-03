# Exercise | Containers Monitor Networking

1) Pull and run the "mysql" container image with the name "network-test", exposing the 3306 port to the 3306 on the host.

2) Obtain the PID of the container process on the host.

3) Use the `nsenter` command (to execute a command in another namespace) on this PID so to be able to launch a `tcpdump` (to be installed) on the container network interface.

4) From another console connect to the exposed port and make some traffic, monitoring what happens on the tcpdump.

---

## Alternate method to get access to the network namespace:

3) Create the name spaces directory /var/run/netns and link the system namespace associated with the process (/proc/<PID>/ns/net) wit the container ID (/var/run/netns/<containerID>).

   Namespace should now be visible via "ip netns show", and in addition it should be possible to exec commands inside of it, execute tcpdump on this namespace so that you will be able to get see all the traffic passing by eth0.
