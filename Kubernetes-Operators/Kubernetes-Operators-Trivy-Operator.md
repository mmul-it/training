# Lab | Implement a Vulnerability Monitor using the Trivy operator

## Install the Trivy Operator

First of all you'll need to install the [Trivy Operator](https://github.com/aquasecurity/trivy-operator)
on your Kubernetes cluster. To get one check [DevSecOps-Pipeline-Requirements.md](DevSecOps-Pipeline-Requirements.md).
As simple as:

```console
$ export TRIVY_OPERATOR_VERSION=v0.17.1

$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/trivy-operator/$TRIVY_OPERATOR_VERSION/deploy/static/trivy-operator.yaml
customresourcedefinition.apiextensions.k8s.io/clustercompliancereports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/clusterconfigauditreports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/clusterinfraassessmentreports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/clusterrbacassessmentreports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/configauditreports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/exposedsecretreports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/infraassessmentreports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/rbacassessmentreports.aquasecurity.github.io configured
customresourcedefinition.apiextensions.k8s.io/vulnerabilityreports.aquasecurity.github.io configured
namespace/trivy-system configured
secret/trivy-operator created
secret/trivy-operator-trivy-config created
configmap/trivy-operator created
configmap/trivy-operator-trivy-config created
deployment.apps/trivy-operator created
role.rbac.authorization.k8s.io/trivy-operator-leader-election created
rolebinding.rbac.authorization.k8s.io/trivy-operator-leader-election created
configmap/trivy-operator-policies-config created
serviceaccount/trivy-operator created
clusterrole.rbac.authorization.k8s.io/trivy-operator configured
clusterrole.rbac.authorization.k8s.io/aggregate-config-audit-reports-view unchanged
clusterrole.rbac.authorization.k8s.io/aggregate-exposed-secret-reports-view unchanged
clusterrole.rbac.authorization.k8s.io/aggregate-vulnerability-reports-view unchanged
clusterrolebinding.rbac.authorization.k8s.io/trivy-operator unchanged
role.rbac.authorization.k8s.io/trivy-operator created
rolebinding.rbac.authorization.k8s.io/trivy-operator created
service/trivy-operator created
```

The operator should take some time to come up, and to verify that everything
is fine and ready it will be sufficient to check the status of the resources
under the `trivy-system` namespace:

```console
$ kubectl -n trivy-system get all
NAME                                 READY   STATUS    RESTARTS   AGE
pod/trivy-operator-bcdbc766f-gdmfd   1/1     Running   0          5m30s

NAME                     TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/trivy-operator   ClusterIP   None         <none>        80/TCP    5m30s

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/trivy-operator   1/1     1            1           5m30s

NAME                                       DESIRED   CURRENT   READY   AGE
replicaset.apps/trivy-operator-bcdbc766f   1         1         1       5m30s
```

Note that a lot of pods and batch jobs will come and go during the operator
initialization.

## Test the Trivy Operator functionalities

The testing environment will be a namespace called `myns`:

```console
$ kubectl create namespace myns
namespace/myns created
```

To begin the test create a deployment with a container affected with knwon
CRITICAL issues, like `nginx:1.18`:

```console
$ kubectl -n myns create deployment nginx --image public.ecr.aws/nginx/nginx:1.18
deployment.apps/nginx created
```

After some time, two additional resources named `configauditreport` and
`vulnerabilityreport` (which will take longer) should have been created:

```console
$ kubectl -n myns get all,vulnerabilityreport,configauditreport
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-7d79b97979-qvjst   1/1     Running   0          3m10s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           3m10s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-7d79b97979   1         1         1       3m10s

NAME                                                                           REPOSITORY    TAG    SCANNER   AGE
vulnerabilityreport.aquasecurity.github.io/replicaset-nginx-7d79b97979-nginx   nginx/nginx   1.18   Trivy     112s

NAME                                                                   SCANNER   AGE
configauditreport.aquasecurity.github.io/replicaset-nginx-7d79b97979   Trivy     3m9s
```

Details about the two reports can be shown using `kubectl describe`.

The `vulnerabilityreport` resource will show image related informations:

```console
$ kubectl -n myns describe vulnerabilityreports.aquasecurity.github.io replicaset-nginx-7d79b97979-nginx
Name:         replicaset-nginx-7d79b97979-nginx
Namespace:    myns
Labels:       resource-spec-hash=5c4c6c67f7
              trivy-operator.container.name=nginx
              trivy-operator.resource.kind=ReplicaSet
              trivy-operator.resource.name=nginx-7d79b97979
              trivy-operator.resource.namespace=myns
Annotations:  trivy-operator.aquasecurity.github.io/report-ttl: 24h0m0s
API Version:  aquasecurity.github.io/v1alpha1
Kind:         VulnerabilityReport
Metadata:
  Creation Timestamp:  2023-09-21T09:40:47Z
  Generation:          1
  Owner References:
    API Version:           apps/v1
    Block Owner Deletion:  false
    Controller:            true
    Kind:                  ReplicaSet
    Name:                  nginx-7d79b97979
    UID:                   4d228bc9-f60c-43a1-8f32-cd29af796062
  Resource Version:        148097
  UID:                     12fa1a5e-29eb-46bd-a81c-c7155a976018
Report:
  Artifact:
    Repository:  nginx/nginx
    Tag:         1.18
  Registry:
    Server:  public.ecr.aws
  Scanner:
    Name:     Trivy
    Vendor:   Aqua Security
    Version:  0.42.0
  Summary:
    Critical Count:  45
    High Count:      124
    Low Count:       153
    Medium Count:    161
    None Count:      0
    Unknown Count:   7
  Update Timestamp:  2023-09-21T09:40:47Z
  Vulnerabilities:
    Fixed Version:
    Installed Version:  1.8.2.2
    Links:
    Primary Link:       https://avd.aquasec.com/nvd/cve-2011-3374
    Resource:           apt
    Score:              3.7
    Severity:           LOW
    Target:
    Title:              It was found that apt-key in apt, all versions, do not correctly valid ...
    Vulnerability ID:   CVE-2011-3374
    ...
    ...
    Fixed Version:      2.28-10+deb10u2
    Installed Version:  2.28-10
    Links:
    Primary Link:       https://avd.aquasec.com/nvd/cve-2021-33574
    Resource:           libc-bin
    Score:              9.8
    Severity:           CRITICAL
    Target:
    Title:              mq_notify does not handle separately allocated thread attributes
    Vulnerability ID:   CVE-2021-33574
    ...
    ...
    Fixed Version:      1:1.2.11.dfsg-1+deb10u1
    Installed Version:  1:1.2.11.dfsg-1
    Links:
    Primary Link:      https://avd.aquasec.com/nvd/cve-2018-25032
    Resource:          zlib1g
    Score:             7.5
    Severity:          HIGH
    Target:
    Title:             A flaw found in zlib when compressing (not decompressing) certain inputs
    Vulnerability ID:  CVE-2018-25032
    Events:                <none>
```

The `configauditreport` resource will show audit related security checks:

```console
$ kubectl -n myns describe configauditreport.aquasecurity.github.io/replicaset-nginx-7d79b97979
Name:         replicaset-nginx-7d79b97979
Namespace:    myns
Labels:       plugin-config-hash=659b7b9c46
              resource-spec-hash=5c4c6c67f7
              trivy-operator.resource.kind=ReplicaSet
              trivy-operator.resource.name=nginx-7d79b97979
              trivy-operator.resource.namespace=myns
Annotations:  trivy-operator.aquasecurity.github.io/report-ttl: 24h0m0s
API Version:  aquasecurity.github.io/v1alpha1
Kind:         ConfigAuditReport
Metadata:
  Creation Timestamp:  2023-09-21T09:39:30Z
  Generation:          1
  Owner References:
    API Version:           apps/v1
    Block Owner Deletion:  false
    Controller:            true
    Kind:                  ReplicaSet
    Name:                  nginx-7d79b97979
    UID:                   4d228bc9-f60c-43a1-8f32-cd29af796062
  Resource Version:        148011
  UID:                     1136acf3-7449-423b-97a5-6cbe590f4b09
Report:
  Checks:
    Category:     Kubernetes Security Check
    Check ID:     KSV016
    Description:  When containers have memory requests specified, the scheduler can make better decisions about which nodes to place pods on, and how to de
al with resource contention.
    Messages:
      Container 'nginx' of ReplicaSet 'nginx-7d79b97979' should set 'resources.requests.memory'
    Severity:     LOW
    Success:      false
    Title:        Memory requests not specified
    ...
    ...
  Scanner:
    Name:     Trivy
    Vendor:   Aqua Security
    Version:  0.14.1
  Summary:
    Critical Count:  0
    High Count:      0
    Low Count:       10
    Medium Count:    2
  Update Timestamp:  2023-09-21T09:39:30Z
Events:              <none>
```

## Activate useful utilities with kubectl

- Install krew:

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

Install `who-can` and `tree` kubectl plugins:

```console
$ kubectl krew install who-can
...

$ kubectl krew install tree
...
```

List who can list `vulnerabilityreports`:

```console
$ kubectl who-can list vulnerabilityreports
No subjects found with permissions to list vulnerabilityreports assigned through RoleBindings

CLUSTERROLEBINDING                           SUBJECT                         TYPE            SA-NAMESPACE
cluster-admin                                system:masters                  Group
dashboard-viewer-rolebinding                 dashboard-user                  ServiceAccount  kubernetes-dashboard
system:controller:generic-garbage-collector  generic-garbage-collector       ServiceAccount  kube-system
system:controller:namespace-controller       namespace-controller            ServiceAccount  kube-system
system:controller:resourcequota-controller   resourcequota-controller        ServiceAccount  kube-system
system:kube-controller-manager               system:kube-controller-manager  User
trivy-operator                               trivy-operator                  ServiceAccount  trivy-system
```

Display the tree view of the `trivy-operator` deployment:

```console
$ kubectl tree -n trivy-system deployment trivy-operator
NAMESPACE     NAME                                                                         READY  REASON  AGE
trivy-system  Deployment/trivy-operator                                                    -              118m
trivy-system  ├─ReplicaSet/trivy-operator-5cd7878587                                       -              117m
trivy-system  │ ├─ConfigAuditReport/replicaset-trivy-operator-5cd7878587                   -              117m
trivy-system  │ ├─ExposedSecretReport/replicaset-trivy-operator-5cd7878587-trivy-operator  -              116m
trivy-system  │ ├─Pod/trivy-operator-5cd7878587-vgxtg                                      True           117m
trivy-system  │ ├─SbomReport/replicaset-trivy-operator-5cd7878587-trivy-operator           -              116m
trivy-system  │ └─VulnerabilityReport/replicaset-trivy-operator-5cd7878587-trivy-operator  -              116m
trivy-system  └─ReplicaSet/trivy-operator-bcdbc766f                                        -              118m
```
