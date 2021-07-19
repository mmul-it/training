# Exercise 003 - Explore the various OpenShift elements - Solutions

---

1. Load the oc environment via ```crc oc-env```:

   ```console
   eval $(crc oc-env)
   ```

2. Use oc login as developer:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.

   You don't have any projects. You can try to create a new project, by running

       oc new-project <projectname>
   ```

   And check permissions:

   ```console
   > oc projects
   You are not a member of any projects. You can request a project to be created with the 'new-project' command.
   ```

   Then do the same as kubeadmin:

   ```console
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.

   You have access to 62 projects, the list has been suppressed. You can list all projects with 'oc projects'

   Using project "default".

   > oc status
   In project default on server https://api.crc.testing:6443

   svc/openshift - kubernetes.default.svc.cluster.local
   svc/kubernetes - 10.217.4.1:443 -> 6443

   View details with 'oc describe <resource>/<name>' or list resources with 'oc get all'.
   ```

3. Use the oc command to list the available projects:

   ```console
   > oc projects
   You have access to the following projects and can switch between them with ' project <projectname>':

     * default
       kube-node-lease
       kube-public
       kube-system
       openshift
       openshift-apiserver
   ...
   ...
   ```

4. First you need to get into the openshift-dns project:

   ```console
   > oc project openshift-dns
   Now using project "openshift-dns" on server "https://api.crc.testing:6443".
   ```

   Then you can use the 'oc get all' command to query for all the elements:

   ```console
   > oc get all
   NAME                    READY   STATUS    RESTARTS   AGE
   pod/dns-default-pc2tf   3/3     Running   0          13d

   NAME                  TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                  AGE
   service/dns-default   ClusterIP   10.217.4.10   <none>        53/UDP,53/TCP,9154/TCP   13d

   NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
   daemonset.apps/dns-default   1         1         1       1            1           kubernetes.io/os=linux   13d
   ```

5. Use login to become developer user again:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.

   You don't have any projects. You can try to create a new project, by running

       oc new-project <projectname>

   > oc whoami
   developer
   ```

   Then following the suggestion, use 'oc new-project' to create a new project:

   ```console
   > oc new-project test-project
   Now using project "test-project" on server "https://api.crc.testing:6443".

   You can add applications to this project with the 'new-app' command. For example, try:

       oc new-app rails-postgresql-example

   to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

       kubectl create deployment hello-node --image=k8s.gcr.io/serve_hostname
   ```

6. The new project is, of course, empty:

   ```console
   > oc get all
   No resources found in test-project namespace.
   ```
