# Exercise 006 - Create a project and switch between projects - Sloutions

1) Login via 'oc login':

> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
...

> oc get projects
NAME                            DISPLAY NAME   STATUS
default                                                           Active
kube-node-lease                                                   Active
kube-public                                                       Active
kube-system                                                       Active
openshift                                                         Active
openshift-apiserver                                               Active
openshift-apiserver-operator                                      Active
openshift-authentication                                          Active
openshift-authentication-operator                                 Active
openshift-cloud-credential-operator                               Active
...

2) Use 'oc new-project' to create a new one:

> oc new-project test --description "Test Project for course" --display-name "Test Project"
Now using project "test" on server "https://api.crc.testing:6443".
...

3) oc get project
NAME                            DISPLAY NAME   STATUS
...
test                            Test Project   Active

Browse the OpenShift web interface;

4) Use again 'oc new-project' for the new one:

> oc new-project new-test --description "NEW Test Project for course" --display-name "NEW Test Project"
Now using project "new-test" on server "https://api.crc.testing:6443".
...

> oc projects
You have access to the following projects and can switch between them with 'oc project <projectname>':

...
  * new-test - NEW Test Project
...
    test - Test Project

5) Use 'oc login' to log as developer:

> oc login -u developer
Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
...

> oc get project
No resources found

> oc project test
error: You are not a member of project "test".
You are not a member of any projects. You can request a project to be created with the 'new-project' command.
To see projects on another server, pass '--server=<server>'.

6) Moving back to kubeadmin, delete the two created projects:

> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
...

> oc delete project test
project.project.openshift.io "test" deleted

> oc delete project new-test
project.project.openshift.io "new-test" deleted
