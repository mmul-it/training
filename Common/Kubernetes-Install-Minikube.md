# Lab | Install Minikube

1. Your system should have, at least:
   - 2 CPUs or more
   - 2GB of free memory
   - 20GB of free disk space
   - Internet connection
   - Container or virtual machine manager, such as: Docker, QEMU, Hyperkit, Hyper-V, KVM, Parallels, Podman, VirtualBox, or VMware Fusion/Workstation

2. Download and make it executable in `/usr/local/bin`:

   ```console
   > curl -O https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

   > chmod +x minikube-linux-amd64
   ```

3. Copy the binary in your $PATH:

   ```console
   > sudo mv minikube-linux-amd64 /usr/local/bin/minikube
   ```

4. Start minikube:

   ```console
   > minikube start
   😄  minikube v1.28.0 on Linuxmint 21
   ✨  Automatically selected the docker driver. Other choices: kvm2, ssh, qemu2 (experimental)
   📌  Using Docker driver with root privileges
   👍  Starting control plane node minikube in cluster minikube
   🚜  Pulling base image ...
   💾  Downloading Kubernetes v1.25.3 preload ...
       > preloaded-images-k8s-v18-v1...:  385.44 MiB / 385.44 MiB  100.00% 3.14 Mi
   🔥  Creating docker container (CPUs=2, Memory=7900MB) ...
   🐳  Preparing Kubernetes v1.25.3 on Docker 20.10.20 ...
       ▪ Generating certificates and keys ...
       ▪ Booting up control plane ...
       ▪ Configuring RBAC rules ...
   🔎  Verifying Kubernetes components...
       ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
   🌟  Enabled addons: storage-provisioner, default-storageclass
   💡  kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
   🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

   ```

   **NOTE 1**: depending on the way you want to install Minikube you can pass
   different driver as paramenter to `minikube start`. By default it will try to
   use the Docker driver, so if you don't have Docker installed on your
   environment you might want to install it by
   [following the official instructions](https://docs.docker.com/engine/install/).

   **NOTE 2**: if you are using Docker remember that your user must be part of
   the `docker` system group. This can be done as follows:

   ```console
   > sudo usermod --append --groups docker <you user name>
   > newgrp docker
   ```

   **NOTE 3**: if you need to enable a specific insecure registry in your
   minikube installation, it is possible to pass the `--insecure-registries`
   options:

   ```console
   > minikube start --insecure-registry=172.16.99.1:5000
   ```

5. Download the `kubectl` command:

   ```console
   > minikube kubectl -- get po -A
       > kubectl.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
       > kubectl:  42.93 MiB / 42.93 MiB [--------------] 100.00% 3.49 MiB p/s 13s
   NAMESPACE     NAME                               READY   STATUS    RESTARTS        AGE
   kube-system   coredns-565d847f94-bxrb6           1/1     Running   0               2m38s
   kube-system   etcd-minikube                      1/1     Running   0               2m52s
   kube-system   kube-apiserver-minikube            1/1     Running   0               2m52s
   kube-system   kube-controller-manager-minikube   1/1     Running   0               2m51s
   kube-system   kube-proxy-pjz5z                   1/1     Running   0               2m38s
   kube-system   kube-scheduler-minikube            1/1     Running   0               2m52s
   kube-system   storage-provisioner                1/1     Running   2 (2m38s ago)   2m51s
   ```
   
   Make it available in your shell:
   
   ```console
   > find .minikube/ -name kubectl
   .minikube/cache/linux/amd64/v1.25.3/kubectl

   > echo 'PATH=.minikube/cache/linux/amd64/v1.25.3/:$PATH' >> ~/.bash_profile

   > source ~/.bash_profile

   > kubectl get po -A
   NAMESPACE     NAME                               READY   STATUS    RESTARTS     AGE
   kube-system   coredns-565d847f94-bxrb6           1/1     Running   0            6m
   kube-system   etcd-minikube                      1/1     Running   0            6m14s
   kube-system   kube-apiserver-minikube            1/1     Running   0            6m14s
   kube-system   kube-controller-manager-minikube   1/1     Running   0            6m13s
   kube-system   kube-proxy-pjz5z                   1/1     Running   0            6m
   kube-system   kube-scheduler-minikube            1/1     Running   0            6m14s
   kube-system   storage-provisioner                1/1     Running   2 (6m ago)   6m13s
   ```

6. The `kubectl` command can be used to produce a bash completion file to be
   included in your shell.

   The `bash-completion` package is mandatory:

   ```console
   > sudo yum -y install bash-completion
   ```

   And then the completion can be activated:

   ```console
   > kubectl completion bash > ~/.kubectl-completion
 
   > echo "source ~/.kubectl-completion" >> ~/.bash_profile
 
   > source ~/.bash_profile

   > kubectl <PRESS TAB>
   annotate       attach         cluster-info   cordon         describe       exec           kustomize      patch          replace        set            version
   api-resources  auth           completion     cp             diff           explain        label          plugin         rollout        taint          wait
   api-versions   autoscale      config         create         drain          expose         logs           port-forward   run            top            
   apply          certificate    convert        delete         edit           get            options        proxy          scale          uncordon 
   ```
