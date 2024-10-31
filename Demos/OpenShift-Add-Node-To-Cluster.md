# Demonstration | OpenShift: Add a node to the existing cluster

First step is to boot the machine using `rhcos-live.x86_64.iso`, and set network
accordingly to cluster environment.
After this it is possible to launch the coreos installation:

```console
$ sudo coreos-installer install --copy-network --ignition-url=http://training-adm:8080/worker.ign /dev/sda --insecure-ignition
...
```

On the `training-adm` machine after some time a request for a 'bootstrapper'
certificate approval will appear:

```console
$ oc get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR
csr-vgncl   21s   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
```

Certificate must then be approved:

```console
$ oc adm certificate approve csr-vgncl
certificatesigningrequest.certificates.k8s.io/csr-vgncl approved
```

At this point a second request of approval, related to the specific node will
appear:

```console
$ oc get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR                                                                    CONDITION
csr-b29t9   0s    kubernetes.io/kubelet-serving                 system:node:training-ootr-04                                                 Pending
csr-vgncl   52s   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper    Approved,Issued
```

Also this one will need to be approved:

```console
$ oc adm certificate approve csr-b29t9
certificatesigningrequest.certificates.k8s.io/csr-b29t9 approved
```

So once all the certificates are approved:

```console
$ oc get csr
NAME        AGE   SIGNERNAME                                    REQUESTOR                                                                   CONDITION
csr-b29t9   10s   kubernetes.io/kubelet-serving                 system:node:training-ootr-04                                                Approved,Issued
csr-vgncl   62s   kubernetes.io/kube-apiserver-client-kubelet   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Approved,Issued
```

Node will appear in the nodes list, initially as "NotReady":

```console
$ oc get nodes
NAME               STATUS     ROLES           AGE   VERSION
training-ootr-01   Ready      control-plane,master,worker   34d   v1.30.4
training-ootr-02   Ready      control-plane,master,worker   34d   v1.30.4
training-ootr-03   Ready      control-plane,master,worker   34d   v1.30.4
training-ootr-04   NotReady   worker          25s   v1.30.4
```

And after some time, it will be fully part of the cluster, 'Ready':

```console
$ oc get nodes
NAME               STATUS     ROLES           AGE   VERSION
training-ootr-01   Ready      control-plane,master,worker   34d   v1.30.4
training-ootr-02   Ready      control-plane,master,worker   34d   v1.30.4
training-ootr-03   Ready      control-plane,master,worker   34d   v1.30.4
training-ootr-04   Ready      worker          61m   v1.30.4
```
