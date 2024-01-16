# Demonstration | Force the namespace PID of your container

Spot the difference between:

```console
$ docker run --pid=host -it alpine ps -ef
PID   USER     TIME  COMMAND
    1 root      0:06 {systemd} /sbin/init
    2 root      0:00 [kthreadd]
    4 root      0:00 [kworker/0:0H]
    6 root      0:00 [mm_percpu_wq]
    7 root      0:00 [ksoftirqd/0]
    8 root      0:07 [rcu_sched]
...
...
```

And

```console
$ docker run -it alpine ps -ef
PID   USER     TIME  COMMAND
    1 root      0:00 ps -ef
```

The second container run is limited to its process namespace, the first one is
using the same one as the system, so be careful about using `--pid` option!
