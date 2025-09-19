# Lab | Install Code Ready Containers

In this lab you will install Code Ready Containers, an OpenShift test cluster.

## Download and prepare crc

Register at [https://cloud.redhat.com/openshift/create/local](https://cloud.redhat.com/openshift/create/local)
and download the crc executable and the pull secret.

Uncompress the crc binary:

```console
$ tar -xJvf crc-linux-amd64.tar.xz
crc-linux-*-amd64/
crc-linux-*-amd64/LICENSE
crc-linux-*-amd64/crc
```

Copy the binary in your `$PATH`:

```console
$ sudo cp crc-linux-*-amd64/crc /usr/local/bin/
(no output)
```

And enable the user to be part of the `libvirt` group:

```console
$ sudo usermod -a -G libvirt $USER
(no output)

$ newgrp libvirt
(no output)
```

Remember that CRC is not suitable for Virtual Machines, unless you have tons of
CPUs and RAM and the VM is configured with `host-passthrough` for the CPU, so
that para-virtualization can happen.

### Debian pre-requirements

CRC is meant to be running on Red Hat based hosts. On a Debian based system,
there are some requrements that need to be filled before starting the setup.

If it's not available the `virtiofsd` service (a daemon for sharing host
directories with virtual machines or other guest using virtio-fs) needs to be
installed as follows:

```console
$ sudo apt -y install virtiofsd
...
```

Then every time a `crc` command is launched, the `machinectl` command needs to
be launched, so that the user can connect with the DBUS Linux system:

```console
$ sudo machinectl shell --uid=$UID
Connected to the local host. Press ^] three times within 1s to exit session.
```

It is possible to avoid this by launching once and for all the `loginctl`
command to enable lingering, to tell `systemd-logind` to always keep a user
manager running, even without an active login session:

```console
$ sudo loginctl enable-linger $USER
(no output)
```

From now on the `crc` binary should behave the same as in Red Hat based systems.

## Start crc

Launch `crc setup` (this might take a lot of time depending on you connection):

```console
$ crc setup
INFO Using bundle path /home/rasca/.crc/cache/crc_libvirt_4.13.6_amd64.crcbundle
INFO Checking if running as non-root
...
...
INFO Checking if CRC bundle is extracted in '$HOME/.crc'
INFO Checking if /home/rasca/.crc/cache/crc_libvirt_4.13.6_amd64.crcbundle exists
INFO Getting bundle for the CRC executable
INFO Downloading bundle: /home/rasca/.crc/cache/crc_libvirt_4.13.6_amd64.crcbundle...
4.00 GiB / 4.00 GiB [------------------] 100.00% 14.16 MiB/s
INFO Uncompressing /home/rasca/.crc/cache/crc_libvirt_4.13.6_amd64.crcbundle
crc.qcow2:  15.24 GiB / 15.24 GiB [------------------] 100.00%
oc:  141.84 MiB / 141.84 MiB [------------------] 100.00%
Your system is correctly setup for using CRC. Use 'crc start' to start the instance
```

The first time launching `crc start` the pull secret will be requested, and
depending on the available resources it could be useful to increase the defaults
to get better performances, such as `--disk-size` (by default 31GB) and
`--memory` (by default 10752):

```console
$ crc start --disk-size=64 --memory=16384
INFO Checking if running as non-root
...
...
You can copy it from the Pull Secret section of https://console.redhat.com/openshift/create/local.
? Please enter the pull secret ************************************************
...
...
INFO Starting openshift instance... [waiting for the cluster to stabilize]
...
...
Started the OpenShift cluster.

The server is accessible via web console at:
  https://console-openshift-console.apps-crc.testing

Log in as administrator:
  Username: kubeadmin
  Password: FCkt2-5DXS7-uczua-BCkBY

Log in as user:
  Username: developer
  Password: developer

Use the 'oc' command line interface:
  $ eval $(crc oc-env)
  $ oc login -u developer https://api.crc.testing:6443
```

## Enable the oc command

Eval the `crc oc-env` command to start using the `oc` command and put it
in the `~/.bashrc` file:

```console
$ eval $(crc oc-env)

$ oc get nodes
NAME                 STATUS   ROLES                         AGE   VERSION
crc-2zx29-master-0   Ready    control-plane,master,worker   32d   v1.26.6+73ac561

$ echo 'eval $(crc oc-env)' >> ~/.bashrc
```

Enable the `oc` command bash completion inside the local `.bashrc` file:

```console
$ sudo dnf -y install bash-completion
...
...

$ source /etc/profile.d/bash_completion.sh
(no output)

$ oc completion bash > ~/.oc-completion
(no output)

$ echo "source ~/.oc-completion" >> ~/.bashrc
(no output)
```

Than, if you logout and login from the console, you should be able to use
the completion:

```console
$ oc s # <-------- Press TAB
scale        (Set a new size for a deployment, replica set, or replication controller)
secrets      (Manage secrets)
set          (Commands that help set specific features on objects)
start-build  (Start a new build)
status       (Show an overview of the current project)
```
