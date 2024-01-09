# Demonstration | OpenShift: Add a node to the existing cluster

First step is to boot the machine using `rhcos-live.x86_64.iso`, and set network
accordingly to cluster environment.
After this it is possible to launch the coreos installation:

```console
$ sudo coreos-installer install --copy-network --ignition-url=http://ocp-bastion.test.kiratech.local/openshift-install-dir/worker.ign /dev/sda --insecure-ignition
...
```

On the bastion machine after some time a request for a 'bootstrapper'
certificate approval will appear:

```console
[root@ocp-bastion ~]# oc get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR
csr-vgncl   21s   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
```

Certificate must then be approved:

```console
[root@ocp-bastion ~]# oc adm certificate approve csr-vgncl
certificatesigningrequest.certificates.k8s.io/csr-vgncl approved
```

At this point a second request of approval, related to the specific node will
appear:

```console
[root@ocp-bastion ~]# oc get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR                                                                    CONDITION
csr-b29t9   0s    kubernetes.io/kubelet-serving                 system:node:ocp-lab-4.test.kiratech.local                                 Pending
csr-vgncl   52s   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper    Approved,Issued
```

Also this one will need to be approved:

```console
[root@ocp-bastion ~]# oc adm certificate approve csr-b29t9
certificatesigningrequest.certificates.k8s.io/csr-b29t9 approved
```

So once all the certificates are approved:

```console
[root@ocp-bastion ~]# oc get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR                                                                   CONDITION
csr-b29t9   10s   kubernetes.io/kubelet-serving                 system:node:ocp-lab-4.test.kiratech.local                                Approved,Issued
csr-vgncl   62s   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Approved,Issued
```

Node will appear in the nodes list, initially as "NotReady":

```console
[root@ocp-bastion ~]# oc get nodes
NAME                            STATUS     ROLES           AGE   VERSION
ocp-lab-1.test.kiratech.local   Ready      master,worker   34d   v1.20.0+df9c838
ocp-lab-2.test.kiratech.local   Ready      master,worker   34d   v1.20.0+df9c838
ocp-lab-3.test.kiratech.local   Ready      master,worker   34d   v1.20.0+df9c838
ocp-lab-4.test.kiratech.local   NotReady   worker          25s   v1.20.0+df9c838
```

And after some time, it will be fully part of the cluster, 'Ready':

```console
[root@ocp-bastion ~]# oc get nodes
NAME                            STATUS     ROLES           AGE   VERSION
ocp-lab-1.test.kiratech.local   Ready      master,worker   34d   v1.20.0+df9c838
ocp-lab-2.test.kiratech.local   Ready      master,worker   34d   v1.20.0+df9c838
ocp-lab-3.test.kiratech.local   Ready      master,worker   34d   v1.20.0+df9c838
ocp-lab-4.test.kiratech.local   Ready      worker          61m   v1.20.0+df9c838
```
