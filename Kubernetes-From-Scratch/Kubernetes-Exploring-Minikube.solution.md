# Exercise | Kubernetes Exploring Minikube | Solution

1. Ensure minikube is up and running:

   ```console
   > minikube status
   minikube
   type: Control Plane
   host: Running
   kubelet: Running
   apiserver: Running
   kubeconfig: Configured
   ```

2. Launch `kubectl cluster-info` and `kubectl version --short`:

   ```console
   > kubectl cluster-info 
   Kubernetes control plane is running at https://192.168.49.2:8443
   CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
   
   To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
   
   > kubectl version --short
   Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
   Client Version: v1.25.3
   Kustomize Version: v4.5.7
   Server Version: v1.25.3
   ```
   
   Release is `v1.25.3`.

3. Launch `kubectl get nodes`:

   ```console
   > kubectl get nodes
   NAME       STATUS   ROLES           AGE   VERSION
   minikube   Ready    control-plane   23h   v1.25.3
   ```

4. Get a shot of the configuration with `kubectl config view`:

   ```console
   apiVersion: v1
   clusters:
   - cluster:
       certificate-authority-data: DATA+OMITTED
       server: https://192.168.122.199:8443
     name: kubernetes
   - cluster:
       certificate-authority: /home/rasca/.minikube/ca.crt
       extensions:
       - extension:
           last-update: Fri, 02 Dec 2022 09:24:47 CET
           provider: minikube.sigs.k8s.io
           version: v1.28.0
         name: cluster_info
       server: https://192.168.49.2:8443
     name: minikube
   contexts:
   - context:
       cluster: minikube
       extensions:
       - extension:
           last-update: Fri, 02 Dec 2022 09:24:47 CET
           provider: minikube.sigs.k8s.io
           version: v1.28.0
         name: context_info
       namespace: default
       user: minikube
     name: minikube
   current-context: minikube
   kind: Config
   preferences: {}
   users:
   - name: minikube
     user:
       client-certificate: /home/rasca/.minikube/profiles/minikube/client.crt
       client-key: /home/rasca/.minikube/profiles/minikube/client.key
   ```
