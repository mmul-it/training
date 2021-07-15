# Exercise 017 - Deploy an application with Helm

1) Install Helm (chose the preferred installation method looking at https://helm.sh/docs/intro/install/)
> curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

2) Create a project named jenkins

> oc new-project jenkins
Now using project "jenkins" on server "https://api.crc.testing:6443"

3) Login as kubeadmin to crc

> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
You have access to 63 projects, the list has been suppressed. You can list all projects with 'oc projects'                                                                   │···············································································
Using project "default".

4) Do "oc adm policy add-scc-to-user anyuid -z default -n jenkins"
 
5) Add Bitnami Helm Repo

> # Check on https://github.com/bitnami/charts/tree/master/bitnami/jenkins in case of an unexpected change of repo url
helm repo add bitnami https://charts.bitnami.com/bitnami

6) Install Jenkins into the namespace jenkins

> helm install my-release bitnami/jenkins -n jenkins
NAME: my-release
LAST DEPLOYED: Thu Jul 15 15:45:05 2021
NAMESPACE: jenkins
STATUS: deployed
REVISION: 1
TEST SUITE: None

7) Check if Jenkins pod is running
> oc get pods -n jenkins -w