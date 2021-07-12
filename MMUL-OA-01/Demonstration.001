# Demonstration 001 - Forcing the namespace PID of your container

1) Spot the difference between:

[core@crc-m89r2-master-0 ~]$ podman run --pid=host -it alpine ps -ef
PID   USER     TIME  COMMAND
    1 nobody    0:18 /usr/lib/systemd/systemd --switched-root --system --deserialize 16
    2 nobody    0:00 [kthreadd]
    3 nobody    0:00 [rcu_gp]
    4 nobody    0:00 [rcu_par_gp]
    6 nobody    0:00 [kworker/0:0H-kb]
    8 nobody    0:00 [mm_percpu_wq]
    9 nobody    0:00 [ksoftirqd/0]
   10 nobody    0:00 [rcu_sched]
...
...

And

[core@crc-m89r2-master-0 ~]$ podman run -it alpine ps -ef
PID   USER     TIME  COMMAND
    1 root      0:00 ps -ef

The second container run is limited to its process namespace, the first one is
using the same one as the system, so be careful about using --pid option!
