# Exercise 006 - Create a project and switch between projects - Sloutions

1. Login via ```oc login```:

   ```console
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
   ```

2. Use ```oc new-project``` to create a new one:

   ```console
   > oc new-project test --description "Test Project for course" --display-name "Test Project"
   Now using project "test" on server "https://api.crc.testing:6443".
   ...
   ```

3. Use ```oc get project``` to see the status of the project:

   ```console
   > oc get project
   NAME                            DISPLAY NAME   STATUS
   ...
   test                            Test Project   Active

   Browse the OpenShift web interface;
   ```

4. Use ```oc login``` to log as developer:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...

   > oc get project
   No resources found

   > oc project test
   error: You are not a member of project "test".
   You are not a member of any projects. You can request a project to be created with the 'new-project' command.
   To see projects on another server, pass '--server=<server>'.
   ```

5. Moving back to ```kubeadmin```, delete the two created projects:

   ```console
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ...

   > oc delete project test
   project.project.openshift.io "test" deleted
   ```
