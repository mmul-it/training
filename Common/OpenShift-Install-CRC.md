# Lab | Install Code Ready Containers

In this lab we will install Code Ready Containers to get a workable OpenShift
installation. We will prepare the environment, download and uncompress the [crc executable](https://cloud.redhat.com/openshift/create/local),
put the crc executable into our `$PATH` and then integrate the bash completion
into the system.

---

1. Register at [https://cloud.redhat.com/openshift/create/local](https://cloud.redhat.com/openshift/create/local)
   and download the crc executable and the pull secret.

2. Uncompress the crc binary:

   ```console
   [student@crc-1 ~]$ tar -xJvf crc-linux-amd64.tar.xz
   crc-linux-2.25.0-amd64/
   crc-linux-2.25.0-amd64/LICENSE
   crc-linux-2.25.0-amd64/crc
   ```

3. Copy the binary in your `$PATH`:

   ```console
   [rasca@crc-1 ~]$ sudo cp crc-linux-2.25.0-amd64/crc /usr/local/bin/
   ```

4. Launch `crc setup` (this might take a lot of time depending on your
   connection):

   ```console
   [rasca@crc-1 ~]$ crc setup
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

   The first time launching `crc start` the pull secret will be requested:

   ```console
   [rasca@crc-1 ~]$ crc start
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

5. Eval the `crc oc-env` command to start using the `oc` command and put it
   in the `~/.bashrc` file:

   ```console
   [rasca@crc-1 ~]$ eval $(crc oc-env)

   [rasca@crc-1 ~]$ oc get nodes
   NAME                 STATUS   ROLES                         AGE   VERSION
   crc-2zx29-master-0   Ready    control-plane,master,worker   32d   v1.26.6+73ac561

   [rasca@crc-1 ~]$ echo 'eval $(crc oc-env)' >> ~/.bashrc
   ```

6. Enable the `oc` command bash completion inside the local `.bashrc` file:

   ```console
   [rasca@crc-1 ~]$ sudo dnf -y install bash-completion
   ...
   ...

   [rasca@crc-1 ~]$ oc completion bash > ~/.oc-completion

   [rasca@crc-1 ~]$ echo "source ~/.oc-completion" >> ~/.bashrc
   ```

   Than, if you logout and login from the console, you should be able to use
   the completion:

   ```console
   [rasca@crc-1 ~]$ oc s # <-------- Press TAB
   scale        (Set a new size for a deployment, replica set, or replication controller)
   secrets      (Manage secrets)
   set          (Commands that help set specific features on objects)
   start-build  (Start a new build)
   status       (Show an overview of the current project)
   ```
