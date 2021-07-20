# Exercise 017 - Deploy an application with Helm

---

1. Install Helm (chose the preferred installation method looking at https://helm.sh/docs/intro/install/)

   ```console
   > curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
   chmod 700 get_helm.sh

   > ./get_helm.sh
   ```

2. Create a project named 'jenkins' as 'developer':

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...

   > oc new-project jenkins
   Now using project "jenkins" on server "https://api.crc.testing:6443"
   ```

3. Login as 'kubeadmin':

   ```
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ...

   > oc adm policy add-scc-to-user anyuid -z default -n jenkins
   clusterrole.rbac.authorization.k8s.io/system:openshift:scc:anyuid added: "default"
   ```

5. Add Bitnami Helm Repo (check on https://github.com/bitnami/charts/tree/master/bitnami/jenkins
   in case of an unexpected change of repo url:

   ```console
   > helm repo add bitnami https://charts.bitnami.com/bitnami
   WARNING: "kubernetes-charts.storage.googleapis.com" is deprecated for "stable" and will be deleted Nov. 13, 2020.
   WARNING: You should switch to "https://charts.helm.sh/stable" via:
   WARNING: helm repo add "stable" "https://charts.helm.sh/stable" --force-update
   "bitnami" has been added to your repositories> helm repo add bitnami https://charts.bitnami.com/bitnami
   ```

6. Install Jenkins into the namespace jenkins:

   ```console
   > helm install my-release bitnami/jenkins -n jenkins
   WARNING: "kubernetes-charts.storage.googleapis.com" is deprecated for "stable" and will be deleted Nov. 13, 2020.
   WARNING: You should switch to "https://charts.helm.sh/stable" via:
   WARNING: helm repo add "stable" "https://charts.helm.sh/stable" --force-update
   NAME: my-release
   LAST DEPLOYED: Tue Jul 20 14:20:51 2021
   NAMESPACE: jenkins
   STATUS: deployed
   REVISION: 1
   TEST SUITE: None
   NOTES:
   ** Please be patient while the chart is being deployed **

   1. Get the Jenkins URL by running:

   ** Please ensure an external IP is associated to the my-release-jenkins service before proceeding **
   ** Watch the status using: kubectl get svc --namespace jenkins -w my-release-jenkins **

     export SERVICE_IP=$(kubectl get svc --namespace jenkins my-release-jenkins --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
     echo "Jenkins URL: http://$SERVICE_IP/"

   2. Login with the following credentials

     echo Username: user
     echo Password: $(kubectl get secret --namespace jenkins my-release-jenkins -o jsonpath="{.data.jenkins-password}" | base64 --decode)
   ```

7. Check if Jenkins pod is running:

   ```console
   > oc get pods -n jenkins -w
   NAME                                  READY   STATUS    RESTARTS   AGE
   my-release-jenkins-75fcd8f4c6-ljz5f   0/1     Running   0          71s
   my-release-jenkins-75fcd8f4c6-ljz5f   1/1     Running   0          89s

   > oc expose svc/my-release-jenkins
   route.route.openshift.io/my-release-jenkins exposed
   ```

   Following the output from the deployment, check the password:

   ```console
   > kubectl get secret --namespace jenkins my-release-jenkins -o jsonpath="{.data.jenkins-password}" | base64 --decode
   3QmyCwwNX4
   ```

   Now you'll be ready to login into the Jenkins web interface, exposed earlier
   pointing web browser to http://my-release-jenkins-jenkins.apps-crc.testing.

   When you're done, you can cleanup everything:

   ```console
   > oc delete project jenkins
   project.project.openshift.io "jenkins" deleted
   ```
