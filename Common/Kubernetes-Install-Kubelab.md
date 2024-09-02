# Lab | Install Kubelab

In this lab you will prepare a Kubernetes cluster using four internal machines.

## Launch the Kubelab playbook

In this lab you will implement the sample cluster into the four available machines, by
using the [Kubelab](https://github.com/mmul-it/kubelab) project.

Machines should already be available, and the only needed steps are the ones to
effectively install the clusters.

First activate the Python Virtual env to run ansible:

```console
$ source ansible-venv/bin/activate
(ansible-venv) $
```

And then launch the playbooks pointing to the `training_kfs_kubelab` inventory,
using the `training_kfs_kubelab` as `k8s_host_group`:

```console
(ansible-venv) $ ansible-playbook -i kiralab/ -e k8s_host_group=training_kfs mmul.kubelab/tests/kubelab.yml
...
PLAY RECAP *******************************************************************************************************
training-kfs-01            : ok=61   changed=43   unreachable=0    failed=0    skipped=30   rescued=0    ignored=0
training-kfs-02            : ok=39   changed=30   unreachable=0    failed=0    skipped=37   rescued=0    ignored=0
training-kfs-03            : ok=39   changed=30   unreachable=0    failed=0    skipped=37   rescued=0    ignored=0
```

## Install kubectl

Make `kubectl` available to the system:

```console
$ export KUBE_VERSION='v1.30.4'

$ curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
...

$ chmod -v +x kubectl && sudo mv kubectl /usr/local/bin
mode of 'kubectl' changed from 0664 (rw-rw-r--) to 0775 (rwxrwxr-x)
```

And use it to check the cluster:

```console
$ export KUBECONFIG=~/training-kfs/admin.conf
(no output)

$ kubectl cluster-info
Kubernetes control plane is running at https://192.168.99.199:8443
CoreDNS is running at https://192.168.99.199:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

$ kubectl get nodes
NAME              STATUS   ROLES           AGE     VERSION
training-kfs-01   Ready    control-plane   3m39s   v1.30.4
training-kfs-02   Ready    control-plane   3m8s    v1.30.4
training-kfs-03   Ready    control-plane   2m32s   v1.30.4
```

## Extend kubectl functionalities

There are plenty of ways to extend `kubectl` functionalies, follow [Kubernetes-Kubectl-Improvements.md](Kubernetes-Kubectl-Improvements.md)
to activate some of them.
