# Exercise 001 - Install Code Ready Containers - Solutions

1. Register in [https://cloud.redhat.com/openshift/create/local](https://cloud.redhat.com/openshift/create/local) and download the crc executable and the pull secret

2. Uncompress the crc binary:

   ```console
   > tar -xJvf crc-linux-amd64.tar.xz
   crc-linux-1.29.1-amd64/
   crc-linux-1.29.1-amd64/LICENSE
   crc-linux-1.29.1-amd64/crc
   ```

3. Copy the binary in your $PATH:

   ```console
   > sudo cp crc-linux-1.29.1-amd64/crc /usr/local/bin/
   ```

4. Launch setup, insert the pull secret when asked, and then start crc:

   ```console
   > crc setup
   INFO Checking if running as non-root
   INFO Checking if running inside WSL2
   ...
   ...
   Your system is correctly setup for using CodeReady Containers, you can now run 'crc start' to start the OpenShift cluster
   ```

   ```console
   > crc start
   INFO Checking if running as non-root
   INFO Checking if running inside WSL2
   ...
   ...
   INFO Starting OpenShift cluster... [waiting for the cluster to stabilize]
   ...
   ...
   Started the OpenShift cluster.

   The server is accessible via web console at:
     https://console-openshift-console.apps-crc.testing

   Log in as administrator:
     Username: kubeadmin
     Password: eSW4F-TXT9I-MqUAA-6hvbW

   Log in as user:
     Username: developer
     Password: developer

   Use the 'oc' command line interface:
     $ eval $(crc oc-env)
     $ oc login -u developer https://api.crc.testing:6443
   ```

5. Eval the oc-env and podman-env to start using the oc command:

   ```console
   > eval $(crc oc-env)
   > eval $(crc podman-env)
   ```

6. Put the different completion inside your local .bashrc file:

   ```console
   > oc completion bash > ~/.oc-completion
   > echo "source ~/.oc-completion" >> ~/.bashrc
   > podman-remote completion bash > ~/.podman-completion
   > echo "source ~/.podman-completion" >> ~/.bashrc
   ```
