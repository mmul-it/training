# Exercise 007 - Playing with cluster roles - Solutions

1) First login as 'kubeadmin':

> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
...

> oc describe clusterrole self-provisioner
Name:         self-provisioner
Labels:       <none>
Annotations:  openshift.io/description: A user that can request projects.
              rbac.authorization.kubernetes.io/autoupdate: true
PolicyRule:
  Resources                             Non-Resource URLs  Resource Names  Verbs
  ---------                             -----------------  --------------  -----
  projectrequests                       []                 []              [create]
  projectrequests.project.openshift.io  []                 []              [create]

2) By using 'oc adm policy remove-cluster-role-from-group' remove role
'self-provisioner' from groups 'system:authenticated' and
'system:authenticated:oauth':

> oc adm policy remove-cluster-role-from-group self-provisioner system:authenticated system:authenticated:oauth
Warning: Your changes may get lost whenever a master is restarted, unless you prevent reconciliation of this rolebinding using the following command: oc annotate clusterrolebinding.rbac self-provisioners 'rbac.authorization.kubernetes.io/autoupdate=false' --overwrite
clusterrole.rbac.authorization.k8s.io/self-provisioner removed: ["system:authenticated" "system:authenticated:oauth"]

3) Become the 'developer' user:

> oc login -u developer
Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.

You don't have any projects. Contact your system administrator to request a project.

Note the message above about "asking to administrator".

> oc new-project my-new-project
Error from server (Forbidden): You may not request a new project via this API.

4) Login back as 'kubeadmin':

> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
...

> oc adm policy add-cluster-role-to-user self-provisioner developer
clusterrole.rbac.authorization.k8s.io/self-provisioner added: "developer"

5) Login back as 'developer':

> oc login -u developer
Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
...

> oc new-project my-new-project
Now using project "my-new-project" on server "https://api.crc.testing:6443".
...

6) Cleanup everything:

> oc delete project my-new-project
project.project.openshift.io "my-new-project" deleted

> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
...

> oc adm policy remove-cluster-role-from-user self-provisioner developer
clusterrole.rbac.authorization.k8s.io/self-provisioner removed: "developer"

> oc adm policy add-cluster-role-to-group self-provisioner system:authenticated system:authenticated:oauth
Warning: Group 'system:authenticated' not found
Warning: Group 'system:authenticated:oauth' not found
clusterrole.rbac.authorization.k8s.io/self-provisioner added: ["system:authenticated" "system:authenticated:oauth"]

> oc login -u developer
Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
...

> oc new-project my-new-project
Now using project "my-new-project" on server "https://api.crc.testing:6443".
...

> oc delete project my-new-project
project.project.openshift.io "my-new-project" deleted
