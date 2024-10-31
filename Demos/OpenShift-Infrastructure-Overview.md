# Demonstration | OpenShift: Kiratech infrastructure overview

Checkout all the components for each machine.

## The main host

These are the VMs involved in the OpenShift On The Rocks lab:

```console
$ virsh list
 Id    Name                      State
------------------------------------------
 543   training-adm              running
 556   training-ootr-01          running
 557   training-ootr-02          running
 558   training-ootr-03          running
 559   training-ootr-crc         running
 -     training-ootr-bootstrap   shut off
```

- `training-adm` is the machine where all the infrastructure services run, and
  from where the `openshift-install` command is launched.
- `training-ootr-0*` are the OpenShift nodes.
- `training-ootr-crc` is the machine where *Code Ready Containers* will be
  installed.
- `training-ootr-bootstrap` is the bootstrap used to initialize the OpenShift
  cluster, and after the installation it has been shut down.

## The training-adm vm

Open ports:

```console
[kirater@training-adm ~]$ sudo ss -nltp
State  Recv-Q Send-Q  Local Address:Port    Peer Address:Port Process
LISTEN 0      3000          0.0.0.0:443          0.0.0.0:*     users:(("haproxy",pid=11419,fd=9))
LISTEN 0      3000          0.0.0.0:6443         0.0.0.0:*     users:(("haproxy",pid=11419,fd=7))
LISTEN 0      4096        127.0.0.1:953          0.0.0.0:*     users:(("named",pid=9822,fd=31))
LISTEN 0      128           0.0.0.0:22           0.0.0.0:*     users:(("sshd",pid=896,fd=3))
LISTEN 0      3000          0.0.0.0:22623        0.0.0.0:*     users:(("haproxy",pid=11419,fd=8))
LISTEN 0      3000          0.0.0.0:80           0.0.0.0:*     users:(("haproxy",pid=11419,fd=10))
LISTEN 0      4096          0.0.0.0:111          0.0.0.0:*     users:(("rpcbind",pid=635,fd=4),("systemd",pid=1,fd=110))
LISTEN 0      10            0.0.0.0:1936         0.0.0.0:*     users:(("haproxy",pid=11419,fd=6))
LISTEN 0      10          127.0.0.1:53           0.0.0.0:*     users:(("named",pid=9822,fd=36))
LISTEN 0      10          127.0.0.1:53           0.0.0.0:*     users:(("named",pid=9822,fd=34))
LISTEN 0      10      192.168.99.10:53           0.0.0.0:*     users:(("named",pid=9822,fd=41))
LISTEN 0      10      192.168.99.10:53           0.0.0.0:*     users:(("named",pid=9822,fd=40))
LISTEN 0      4096            [::1]:953             [::]:*     users:(("named",pid=9822,fd=46))
LISTEN 0      128              [::]:22              [::]:*     users:(("sshd",pid=896,fd=4))
LISTEN 0      4096             [::]:111             [::]:*     users:(("rpcbind",pid=635,fd=6),("systemd",pid=1,fd=113))
LISTEN 0      511                 *:8080               *:*     users:(("httpd",pid=96459,fd=4),("httpd",pid=96458,fd=4), ...
LISTEN 0      10              [::1]:53              [::]:*     users:(("named",pid=9822,fd=44))
LISTEN 0      10              [::1]:53              [::]:*     users:(("named",pid=9822,fd=45))
```

Contents of the haproxy configuration file `/etc/haproxy/haproxy.cfg`:

```console
global
  log         127.0.0.1 local2
  pidfile     /var/run/haproxy.pid
  maxconn     4000
  daemon
defaults
  mode                    http
  log                     global
  option                  dontlognull
  option http-server-close
  option                  redispatch
  retries                 3
  timeout http-request    10s
  timeout queue           1m
  timeout connect         10s
  timeout client          1m
  timeout server          1m
  timeout http-keep-alive 10s
  timeout check           10s
  maxconn                 3000
frontend stats
  bind *:1936
  mode            http
  log             global
  maxconn 10
  stats enable
  stats hide-version
  stats refresh 30s
  stats show-node
  stats show-desc Stats for cluster
  stats auth admin:ocp4
  stats uri /stats
listen api-server-6443
  bind *:6443
  mode tcp
  server bootstrap training-ootr-bootstrap.ocp.kiralab.local:6443 check inter 1s backup
  server control-plane-01 training-ootr-01.ocp.kiralab.local:6443 check inter 1s
  server control-plane-02 training-ootr-02.ocp.kiralab.local:6443 check inter 1s
  server control-plane-03 training-ootr-03.ocp.kiralab.local:6443 check inter 1s
listen machine-config-server-22623
  bind *:22623
  mode tcp
  server bootstrap training-ootr-bootstrap.ocp.kiralab.local:22623 check inter 1s backup
  server control-plane-01 training-ootr-01.ocp.kiralab.local:22623 check inter 1s
  server control-plane-02 training-ootr-02.ocp.kiralab.local:22623 check inter 1s
  server control-plane-03 training-ootr-03.ocp.kiralab.local:22623 check inter 1s
listen ingress-router-443
  bind *:443
  mode tcp
  balance source
  server control-plane-01 training-ootr-01.ocp.kiralab.local:443 check inter 1s
  server control-plane-02 training-ootr-02.ocp.kiralab.local:443 check inter 1s
  server control-plane-03 training-ootr-03.ocp.kiralab.local:443 check inter 1s
listen ingress-router-80
  bind *:80
  mode tcp
  balance source
  server control-plane-01 training-ootr-01.ocp.kiralab.local:80 check inter 1s
  server control-plane-02 training-ootr-02.ocp.kiralab.local:80 check inter 1s
  server control-plane-03 training-ootr-03.ocp.kiralab.local:80 check inter 1s
```

Contents of the DNS zone `/var/named/kiralab.local.zone`:

```dns
$TTL 1W
@    IN    SOA    ns1.kiralab.local.    root (
                  2024101700      ; serial
                  3H              ; refresh (3 hours)
                  30M             ; retry (30 minutes)
                  2W              ; expiry (2 weeks)
                  1W )            ; minimum (1 week)
    IN    NS      ns1.kiralab.local.
    IN    MX 10   smtp.kiralab.local.

; Lab
training-adm.kiralab.local.                   IN    A    192.168.99.10
ns1.kiralab.local.                            IN    A    192.168.99.10
smtp.kiralab.local.                           IN    A    192.168.99.10
helper.kiralab.local.                         IN    A    192.168.99.10

; OpenShift On The Rocks
api.ocp.kiralab.local.                        IN    A    192.168.99.10
api-int.ocp.kiralab.local.                    IN    A    192.168.99.10
*.apps.ocp.kiralab.local.                     IN    A    192.168.99.10
training-ootr-bootstrap.ocp.kiralab.local.    IN    A    192.168.99.20
training-ootr-01.ocp.kiralab.local.           IN    A    192.168.99.21
training-ootr-02.ocp.kiralab.local.           IN    A    192.168.99.22
training-ootr-03.ocp.kiralab.local.           IN    A    192.168.99.23
training-ootr-crc.kiralab.local.              IN    A    192.168.99.40

; Kubernetes From Scratch
training-kfs-01.kiralab.local.                IN    A    192.168.99.31
training-kfs-02.kiralab.local.                IN    A    192.168.99.32
training-kfs-03.kiralab.local.                IN    A    192.168.99.33
```

Contents of the DNS zone `/var/named/99.168.192.zone`:

```dns
$ORIGIN 99.168.192.in-addr.arpa.
$TTL 86400
@     IN     SOA    ns1.kiralab.local.     hostmaster.kiralab.local. (
                    2024101700 ; serial
                    21600      ; refresh after 6 hours
                    3600       ; retry after 1 hour
                    604800     ; expire after 1 week
                    86400 )    ; minimum TTL of 1 day

      IN     NS     ns1.kiralab.local.

10    IN     PTR    training-adm.kiralab.local.
10    IN     PTR    api.ocp.kiralab.local.
10    IN     PTR    api-int.ocp.kiralab.local.
20    IN     PTR    training-ootr-bootstrap.ocp.kiralab.local.
21    IN     PTR    training-ootr-01.ocp.kiralab.local.
22    IN     PTR    training-ootr-02.ocp.kiralab.local.
23    IN     PTR    training-ootr-03.ocp.kiralab.local.
31    IN     PTR    training-kfs-01.kiralab.local.
32    IN     PTR    training-kfs-02.kiralab.local.
33    IN     PTR    training-kfs-03.kiralab.local.
40    IN     PTR    training-ootr-crc.kiralab.local.
```

Installation directory (generated by `openshift-installer`):

```console
[root@ocp-bastion ~]# ls -1 /var/www/html/
auth
bootstrap.ign
master.ign
metadata.json
worker.ign
```

OpenShift and Kubernetes status:

```console
$ export KUBECONFIG=/var/www/html/auth/kubeconfig

$ kubectl config get-contexts
CURRENT   NAME    CLUSTER   AUTHINFO   NAMESPACE
*         admin   ocp       admin

$ oc config get-contexts
CURRENT   NAME    CLUSTER   AUTHINFO   NAMESPACE
*         admin   ocp       admin

$ oc get nodes
NAME               STATUS   ROLES                         AGE   VERSION
training-ootr-01   Ready    control-plane,master,worker   13d   v1.30.4
training-ootr-02   Ready    control-plane,master,worker   13d   v1.30.4
training-ootr-03   Ready    control-plane,master,worker   13d   v1.30.4

$ oc projects
You have access to the following projects and can switch between them with ' project <projectname>':

  * default
    kube-node-lease
    kube-public
    kube-system
    openshift
    openshift-apiserver
    openshift-apiserver-operator
...
...

$ oc project openshift-etcd
Now using project "openshift-etcd" on server "https://api.test.kiratech.local:6443".
[root@ocp-bastion ~]# oc get pods
NAME                                                 READY   STATUS      RESTARTS   AGE
etcd-ocp-lab-1.test.kiratech.local                3/3     Running     0          33d
etcd-ocp-lab-2.test.kiratech.local                3/3     Running     11         33d
etcd-ocp-lab-3.test.kiratech.local                3/3     Running     0          33d
etcd-quorum-guard-6cc7f5954d-2kb95                   1/1     Running     0          33d
etcd-quorum-guard-6cc7f5954d-6dbzf                   1/1     Running     0          33d
etcd-quorum-guard-6cc7f5954d-tx988                   1/1     Running     0          34d
installer-2-ocp-lab-1.test.kiratech.local         0/1     Completed   0          34d
...
...
```

## The OCP VMs

These are the OCP VMs:

```console
$ ssh core@training-ootr-01.ocp.kiralab.local
Warning: Permanently added 'training-ootr-01.ocp.kiralab.local' (ED25519) to the list of known hosts.
Red Hat Enterprise Linux CoreOS 417.94.202409121747-0
  Part of OpenShift 4.17, RHCOS is a Kubernetes-native operating system
  managed by the Machine Config Operator (`clusteroperator/machine-config`).

WARNING: Direct SSH access to machines is not recommended; instead,
make configuration changes via `machineconfig` objects:
  https://docs.openshift.com/container-platform/4.17/architecture/architecture-rhcos.html

---
Last login: Wed Oct 23 09:47:59 2024 from 192.168.99.10

[core@training-ootr-01 ~]$ lscpu
Architecture:            x86_64
  CPU op-mode(s):        32-bit, 64-bit
  Address sizes:         39 bits physical, 48 bits virtual
  Byte Order:            Little Endian
CPU(s):                  4
  On-line CPU(s) list:   0-3
Vendor ID:               GenuineIntel
  Model name:            Intel(R) Xeon(R) CPU E3-1275 v6 @ 3.80GHz
    CPU family:          6
    Model:               158
    Thread(s) per core:  1
    Core(s) per socket:  1
    Socket(s):           4
    Stepping:            9
    BogoMIPS:            7584.02
    Flags:               fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc ar
                         ch_perfmon rep_good nopl xtopology cpuid tsc_known_freq pni pclmulqdq vmx ssse3 fma cx16 pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline
                         _timer aes xsave avx f16c rdrand hypervisor lahf_lm abm 3dnowprefetch cpuid_fault pti ssbd ibrs ibpb stibp tpr_shadow flexpriority ept vpid ept_a
                         d fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid mpx rdseed adx smap clflushopt xsaveopt xsavec xgetbv1 xsaves arat vnmi umip md_clear arch
                         _capabilities
Virtualization features:
  Virtualization:        VT-x
  Hypervisor vendor:     KVM
  Virtualization type:   full
Caches (sum of all):
  L1d:                   128 KiB (4 instances)
  L1i:                   128 KiB (4 instances)
  L2:                    16 MiB (4 instances)
  L3:                    64 MiB (4 instances)
NUMA:
  NUMA node(s):          1
  NUMA node0 CPU(s):     0-3
Vulnerabilities:
  Gather data sampling:  Unknown: Dependent on hypervisor status
  Itlb multihit:         Not affected
  L1tf:                  Mitigation; PTE Inversion; VMX flush not necessary, SMT disabled
  Mds:                   Mitigation; Clear CPU buffers; SMT Host state unknown
  Meltdown:              Mitigation; PTI
  Mmio stale data:       Vulnerable: Clear CPU buffers attempted, no microcode; SMT Host state unknown
  Retbleed:              Mitigation; IBRS
  Spec rstack overflow:  Not affected
  Spec store bypass:     Mitigation; Speculative Store Bypass disabled via prctl
  Spectre v1:            Mitigation; usercopy/swapgs barriers and __user pointer sanitization
  Spectre v2:            Mitigation; IBRS, IBPB conditional, STIBP disabled, RSB filling, PBRSB-eIBRS Not affected
  Srbds:                 Unknown: Dependent on hypervisor status
  Tsx async abort:       Not affected

[core@training-ootr-01 ~]$ free -m
               total        used        free      shared  buff/cache   available
Mem:           15993        8407         396          96        7624        7585
Swap:              0           0           0
```
