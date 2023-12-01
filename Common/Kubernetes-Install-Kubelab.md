# Lab | Install Kubelab

This lab will implement the two sample cluster into the four available
machines, by unsing the [Kubelab](https://github.com/mmul-it/kubelab) project.

Machines should already be available, and the only needed steps are the ones to
effectively install the clusters.

First activate the Python Virtual env to run ansible:

```console
$ source ansible-venv/bin/activate
(ansible-venv) $
```

And then launch the playbooks pointing to the different inventories:

```console
(ansible-venv) $ ansible-playbook -i kiralab/ -e k8s_host_group=training_kfs_kubernetes mmul.kubelab/tests/kubelab.yml 
...
PLAY RECAP ***********************************************************************************************************************************************
training-kfs-kubernetes-1  : ok=52   changed=37   unreachable=0    failed=0    skipped=31   rescued=0    ignored=0   
training-kfs-kubernetes-2  : ok=39   changed=30   unreachable=0    failed=0    skipped=37   rescued=0    ignored=0   
training-kfs-kubernetes-3  : ok=39   changed=30   unreachable=0    failed=0    skipped=37   rescued=0    ignored=0

(ansible-venv) $ ansible-playbook -i kiralab/ -e k8s_host_group=training_kfs_kubesingle mmul.kubelab/tests/kubelab.yml
...
PLAY RECAP ***********************************************************************************************************************************************
training-kfs-kubesingle    : ok=46   changed=31   unreachable=0    failed=0    skipped=37   rescued=0    ignored=0
```

Then make `kubectl` available to the system:

```console
$ curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
$ chmod -v +x kubectl && sudo mv kubectl /usr/local/bin
mode of 'kubectl' changed from 0664 (rw-rw-r--) to 0775 (rwxrwxr-x)
```

And use it to check the two clusters:

```console
$ export KUBECONFIG=training-kfs-kubernetes/admin.conf
$ kubectl get nodes
NAME                        STATUS   ROLES           AGE     VERSION
training-kfs-kubernetes-1   Ready    control-plane   7m32s   v1.28.2
training-kfs-kubernetes-2   Ready    control-plane   6m58s   v1.28.2
training-kfs-kubernetes-3   Ready    control-plane   5m57s   v1.28.2

$ export KUBECONFIG=training-kfs-kubesingle/admin.conf
$ kubectl get nodes
NAME                      STATUS   ROLES           AGE   VERSION
training-kfs-kubesingle   Ready    control-plane   94s   v1.28.2
```
