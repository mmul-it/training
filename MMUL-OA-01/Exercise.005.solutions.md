# Exercise 005 - Customize a Deployment on OpenShift - Solutions

---

1. Use the command ```oc new-app``` to create the yaml file:

   ```console
   > oc new-app mariadb MYSQL_USER=user MYSQL_PASSWORD=pass MYSQL_DATABASE=testdb -l db=mariadb > mariadb-deployment.yaml
   ```

2. Check the content of *mariadb-deployment.yaml*:

   ```console
   > cat mariadb-deployment.yaml
   ...
   ```

   Or if you want to extract just the main resources defined:

   ```console
   > grep "  kind:" mariadb-deployment.yaml
     kind: ImageStreamTag
         kind: DockerImage
     kind: Deployment
     kind: Service
   ```

3) While editing the file:
   - In the Deployment section, look for ```spec:``` and its ```replicas:```
     definition.
     Change the value from 1 to 2;
   - In the Deployment section, add ```zone: dmz``` in
     ```metadata:labels:```
     and
     ```spec:template:metadata:labels:```
   - Remove entirely the Service resource (with kind: Service)

4) Login as developer and create the 'my-second-project':

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.

   You don't have any projects. You can try to create a new project, by running

       oc new-project <projectname>

   > oc new-project my-second-project
   Now using project "my-second-project" on server "https://api.crc.testing:6443".

   You can add applications to this project with the 'new-app' command. For example, try:

       oc new-app rails-postgresql-example

   to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

       kubectl create deployment hello-node --image=k8s.gcr.io/serve_hostname
   ```

   Create the deployment with ```oc create -f```:

   ```console
   > oc create -f mariadb-deployment.yaml
   imagestreamtag.image.openshift.io/mariadb:10.3-el8 created
   deployment.apps/mariadb created
   ```

5) Use ```oc describe deployment``` to get details of the deployment:

   ```console
   > oc describe deployment mariadb
   Name:                   mariadb
   Namespace:              my-second-project
   CreationTimestamp:      Wed, 14 Jul 2021 17:10:00 +0200
   Labels:                 app=mariadb
                           app.kubernetes.io/component=mariadb
                           app.kubernetes.io/instance=mariadb
                           db=mariadb
                           zone=dmz
   ...
   ...

   > oc get deployment -l zone=dmz
   NAME      READY   UP-TO-DATE   AVAILABLE   AGE
   mariadb   2/2     2            2           66s

   > oc get pods
   NAME                       READY   STATUS    RESTARTS   AGE
   mariadb-64bcf6dd4c-4vqzs   1/1     Running   0          76s
   mariadb-64bcf6dd4c-l4rdh   1/1     Running   0          80s

   > oc logs mysql-jb97m
   => sourcing 20-validate-variables.sh ...
   => sourcing 25-validate-replication-variables.sh ...
   => sourcing 30-base-config.sh ...
   ---> 15:10:09     Processing basic MySQL configuration files ...
   => sourcing 60-replication-config.sh ...
   => sourcing 70-s2i-config.sh ...
   ---> 15:10:09     Processing additional arbitrary  MySQL configuration provided by s2i ...
   => sourcing 40-paas.cnf ...
   => sourcing 50-my-tuning.cnf ...
   ---> 15:10:09     Initializing database ...
   ...
   ...
   ```

6) Using ```oc delete``` with -l to select zone, delete all the elements:

   ```console
   > oc delete all -l zone=dmz
   pod "mariadb-64bcf6dd4c-4vqzs" deleted
   pod "mariadb-64bcf6dd4c-l4rdh" deleted
   deployment.apps "mariadb" deleted
   replicaset.apps "mariadb-5db7475f4" deleted
   replicaset.apps "mariadb-64bcf6dd4c" deleted

   > oc status
   In project my-second-project on server https://api.crc.testing:6443

   You have no services, deployment configs, or build configs.
   Run 'oc new-app' to create an application.

   > oc delete project my-second-project
   project.project.openshift.io "my-second-project" deleted
   ```
