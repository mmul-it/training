# Lab | Install Kubelab

## Launch the Kubelab playbook

This lab will implement the sample cluster into the four available machines, by
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
(ansible-venv) $ ansible-playbook -i kiralab/ -e k8s_host_group=training_kfs_kubelab mmul.kubelab/tests/kubelab.yml
...
PLAY RECAP ***********************************************************************************************************************************************
training-kfs-kubelab-1     : ok=52   changed=37   unreachable=0    failed=0    skipped=31   rescued=0    ignored=0
training-kfs-kubelab-2     : ok=39   changed=30   unreachable=0    failed=0    skipped=37   rescued=0    ignored=0
training-kfs-kubelab-3     : ok=39   changed=30   unreachable=0    failed=0    skipped=37   rescued=0    ignored=0
training-kfs-kubelab-4     : ok=31   changed=23   unreachable=0    failed=0    skipped=45   rescued=0    ignored=0
```

Then make `kubectl` available to the system:

```console
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
...

$ chmod -v +x kubectl && sudo mv kubectl /usr/local/bin
mode of 'kubectl' changed from 0664 (rw-rw-r--) to 0775 (rwxrwxr-x)
```

And use it to check the cluster:

```console
$ export KUBECONFIG=training-kfs-kubelab/admin.conf
(no output)

$ kubectl cluster-info
Kubernetes control plane is running at https://192.168.99.199:8443
CoreDNS is running at https://192.168.99.199:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

$ kubectl get nodes
NAME                     STATUS   ROLES           AGE     VERSION
training-kfs-kubelab-1   Ready    control-plane   3m8s    v1.28.2
training-kfs-kubelab-2   Ready    control-plane   2m27s   v1.28.2
training-kfs-kubelab-3   Ready    control-plane   87s     v1.28.2
training-kfs-kubelab-4   Ready    <none>          53s     v1.28.2
```
