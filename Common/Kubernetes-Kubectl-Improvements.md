# Lab | Kubernetes kubectl improvements

Whenever you installed Kubernetes following [Kubernetes-Install-Kubelab.md](Kubernetes-Install-Kubelab.md)
or [Kubernetes-Install-Minikube.md](Kubernetes-Install-Minikube.md), in both
cases you should have installed also the `kubectl` command to interact with the
cluster.

This lab helps to improve `kubectl` functionalities by enabling auto completion
and `krew` utilities.

## Enable kubectl command completion

The `kubectl` command can be used to produce a bash completion file to be
included in your shell.

The `bash-completion` package is mandatory for both a Red Hat based
installation:

```console
$ sudo yum -y install bash-completion
...
```

As well as Debian based:

```console
$ sudo apt install -y bash-completion
(no output)
```

Bash completion is usually enabled by default, but can be manually activated:

```console
$ source /etc/profile.d/bash_completion.sh
(no output)
```

Once this is done to enable auto completion with `kubectl` use these commands:

```console
$ kubectl completion bash > ~/.kubectl-completion
(no output)

$ echo "source ~/.kubectl-completion" >> ~/.bash_profile
(no output)

$ source ~/.kubectl-completion
(no output)

$ kubectl <PRESS TAB>
annotate       attach         cluster-info   cordon         describe       exec           kustomize      patch          replace        set            version
api-resources  auth           completion     cp             diff           explain        label          plugin         rollout        taint          wait
api-versions   autoscale      config         create         drain          expose         logs           port-forward   run            top
apply          certificate    convert        delete         edit           get            options        proxy          scale          uncordon
```

Remember that "Tab" is your friend. Use it!

## Use krew to extend kubectl functionalities

To Install krew you will need `git` on your system.

If you use Red Hat based systems install it via:

```console
$ sudo yum -y install git
...
```

or with Debian based system use:

```console
$ sudo apt install -y git
...
```

Then you can proceed by downloading `krew` and installing it:

```console
$ curl -LO https://github.com/kubernetes-sigs/krew/releases/download/v0.4.4/krew-linux_amd64.tar.gz
...

$ tar -xzvf krew-linux_amd64.tar.gz
...

$ sudo mv krew-linux_amd64 /usr/local/bin/krew

$ krew install krew
Adding "default" plugin index from https://github.com/kubernetes-sigs/krew-index.git.
Updated the local copy of plugin index.
Installing plugin: krew
Installed plugin: krew
\
 | Use this plugin:
 |     kubectl krew
 | Documentation:
 |     https://krew.sigs.k8s.io/
 | Caveats:
 | \
 |  | krew is now installed! To start using kubectl plugins, you need to add
 |  | krew's installation directory to your PATH:
 |  |
 |  |   * macOS/Linux:
 |  |     - Add the following to your ~/.bashrc or ~/.zshrc:
 |  |         export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
 |  |     - Restart your shell.
 |  |
 |  |   * Windows: Add %USERPROFILE%\.krew\bin to your PATH environment variable
 |  |
 |  | To list krew commands and to get help, run:
 |  |   $ kubectl krew
 |  | For a full list of available plugins, run:
 |  |   $ kubectl krew search
 |  |
 |  | You can find documentation at
 |  |   https://krew.sigs.k8s.io/docs/user-guide/quickstart/.
 | /
/

$ echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> .bash_profile

$ export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```

There are plenty of plugins that can be installed, we will start with `who-can`
and `tree`:

```console
$ kubectl krew install who-can
...

$ kubectl krew install tree
...
```

With this plugins in place it will be possible to know who can list certain
objects, like Pods:

```console
$ kubectl who-can list pods
No subjects found with permissions to list pods assigned through RoleBindings

CLUSTERROLEBINDING                             SUBJECT                         TYPE            SA-NAMESPACE
cluster-admin                                  system:masters                  Group           
kubeadm:cluster-admins                         kubeadm:cluster-admins          Group           
system:controller:attachdetach-controller      attachdetach-controller         ServiceAccount  kube-system
system:controller:cronjob-controller           cronjob-controller              ServiceAccount  kube-system
system:controller:daemon-set-controller        daemon-set-controller           ServiceAccount  kube-system
system:controller:deployment-controller        deployment-controller           ServiceAccount  kube-system
system:controller:endpoint-controller          endpoint-controller             ServiceAccount  kube-system
system:controller:endpointslice-controller     endpointslice-controller        ServiceAccount  kube-system
system:controller:ephemeral-volume-controller  ephemeral-volume-controller     ServiceAccount  kube-system
system:controller:generic-garbage-collector    generic-garbage-collector       ServiceAccount  kube-system
system:controller:horizontal-pod-autoscaler    horizontal-pod-autoscaler       ServiceAccount  kube-system
system:controller:job-controller               job-controller                  ServiceAccount  kube-system
system:controller:namespace-controller         namespace-controller            ServiceAccount  kube-system
system:controller:node-controller              node-controller                 ServiceAccount  kube-system
system:controller:persistent-volume-binder     persistent-volume-binder        ServiceAccount  kube-system
system:controller:pod-garbage-collector        pod-garbage-collector           ServiceAccount  kube-system
system:controller:pvc-protection-controller    pvc-protection-controller       ServiceAccount  kube-system
system:controller:replicaset-controller        replicaset-controller           ServiceAccount  kube-system
system:controller:replication-controller       replication-controller          ServiceAccount  kube-system
system:controller:resourcequota-controller     resourcequota-controller        ServiceAccount  kube-system
system:controller:statefulset-controller       statefulset-controller          ServiceAccount  kube-system
system:coredns                                 coredns                         ServiceAccount  kube-system
system:kube-controller-manager                 system:kube-controller-manager  User            
system:kube-scheduler                          system:kube-scheduler           User            
trivy-operator                                 trivy-operator                  ServiceAccount  trivy-system
```

Or the tree structure of a deployment:

```console
$ kubectl tree -n kube-system deployment coredns
NAMESPACE    NAME                                                           READY  REASON  AGE
kube-system  Deployment/coredns                                             -              36m
kube-system  └─ReplicaSet/coredns-7db6d8ff4d                                -              35m
kube-system    ├─ConfigAuditReport/replicaset-coredns-7db6d8ff4d            -              24m
kube-system    ├─ExposedSecretReport/replicaset-coredns-7db6d8ff4d-coredns  -              23m
kube-system    ├─Pod/coredns-7db6d8ff4d-bp7r5                               True           35m
kube-system    ├─Pod/coredns-7db6d8ff4d-gwvgl                               True           35m
kube-system    ├─SbomReport/replicaset-coredns-7db6d8ff4d-coredns           -              23m
kube-system    └─VulnerabilityReport/replicaset-coredns-7db6d8ff4d-coredns  -              23m
```
