# Exercise 017 - Deploy an application with Helm

---

1. Install Helm (chose the preferred installation method looking at the
   [installation page](https://helm.sh/docs/intro/install/)):

   ```console
   > curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
   chmod 700 get_helm.sh
   
   > ./get_helm.sh
   ```
2. Create a project named jenkins;

   ```console
   > oc new-project jenkins
   Now using project "jenkins" on server "https://api.crc.testing:6443"
```

3. Login as 'kubeadmin':

   ```
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   You have access to 63 projects, the list has been suppressed. You can list all projects with 'oc projects'

   Using project "default".
   ```

4. Do ```oc adm policy add-scc-to-user anyuid -z default -n jenkins```:

   ```console
   > oc adm policy add-scc-to-user anyuid -z default -n jenkins
   ```

5. Add Bitnami Helm Repo (check on [Bitname GitHub page](https://github.com/bitnami/charts/tree/master/bitnami/jenkins))
   in case of an unexpected change of repo url:

   ```console
   > helm repo add bitnami https://charts.bitnami.com/bitnami
   ```

6. Install Jenkins into the namespace jenkins:

   ```console
   > helm install my-release bitnami/jenkins -n jenkins
   NAME: my-release
   LAST DEPLOYED: Thu Jul 15 15:45:05 2021
   NAMESPACE: jenkins
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   ```

7. Check if Jenkins pod is running:

   ```console
   > oc get pods -n jenkins -w
   ```
