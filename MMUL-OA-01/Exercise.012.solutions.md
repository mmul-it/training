# Exercise 012 - Find HAProxy stats page details - Solutions

_1) As 'kubeadmin', obtain the name of the router pod in the openshift-ingress
   project._

Login as kubeadmin:

```
> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
```

switch to the openshift-ingress namespace:

```
> oc project openshift-ingress
Now using project "openshift-ingress" on server "https://api.crc.testing:6443".
```

list pods in the project:

```
> oc get pods
NAME                             READY   STATUS    RESTARTS   AGE
router-default-5f7c456ff-pxgf7   1/1     Running   2          13d
routes-controller                1/1     Running   0          5h12m
```

the router pod is router-default-5f7c456ff-pxgf7.

_2) Extract metrics informations from that._

Filter by STATS environment variables in the pod specifications:

```
> oc describe pod router-default-5f7c456ff-pxgf7 | grep STATS
STATS_PASSWORD:                            <set to the key 'statsPassword' in secret 'router-stats-default'>  Optional: false
STATS_PORT:                                1936
STATS_USERNAME:                            <set to the key 'statsUsername' in secret 'router-stats-default'>  Optional: false
```

_3) Identify metrics endpoint username and password in the specified secret._

Check if the router-stats-default secret contains the two keys reported in the
previous output:

```
> oc describe secret router-stats-default
Name:         router-stats-default
Namespace:    openshift-ingress
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
statsPassword:  12 bytes
statsUsername:  12 bytes
```

the secret have the Type: Opaque defined, so you need to inspect the yaml of
the secret itself to see the content of those keys:

```
> oc get secret router-stats-default -o yaml | awk '/Username|Password/ && !/f:/'
  statsPassword: Y0dGemMyWm5kbTVu
  statsUsername: ZFhObGNtMW5jbmh3
```

_4) Connect to the CodeReady host and query the /healthz endpoint in the metric
   server._

Using the private key for CodeReady VM in your home directory, you can login
with the core user on that. SSH port may vary on different CodeReady
installations:

```
> ssh -i ~/.crc/machines/crc/id_ecdsa core@127.0.0.1 -p2222
Red Hat Enterprise Linux CoreOS 47.83.202106200838-0
Part of OpenShift 4.7, RHCOS is a Kubernetes native operating system
managed by the Machine Config Operator (`clusteroperator/machine-config`).
...
```

from that you can curl the /healtz endpoint on the haproxy metrics port:

```
[core@crc-4727w-master-0 ~]$ curl http://localhost:1936/healthz ; echo
ok
```