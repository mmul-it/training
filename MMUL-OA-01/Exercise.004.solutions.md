# Exercise 004 - First OpenShift deployment - Solutions

---

1. Make login via ```oc login``` and create a project with
   ```oc new-project```:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.

   You don't have any projects. You can try to create a new project, by running

       oc new-project <projectname>

   > oc new-project my-first-project
   Now using project "my-first-project" on server "https://api.crc.testing:6443".

   You can add applications to this project with the 'new-app' command. For example, try:

       oc new-app rails-postgresql-example

   to build a new example application in Ruby. Or use kubectl to deploy a simple Kubernetes application:

       kubectl create deployment hello-node --image=k8s.gcr.io/serve_hostname
   ```

2. Use ```oc new-app``` to create a new application:

   ```console
   > oc new-app mariadb MYSQL_USER=user MYSQL_PASSWORD=pass MYSQL_DATABASE=testdb
   --> Found image bde1f31 (3 weeks old) in image stream "openshift/mariadb" under tag "10.3-el8" for "mariadb"

       MariaDB 10.3
       ------------
       MariaDB is a multi-user, multi-threaded SQL database server. The container image provides a containerized packaging of the MariaDB mysqld daemon and client application. The mysqld server daemon accepts connections from clients and provides access to content from MariaDB databases on behalf of the clients.

       Tags: database, mysql, mariadb, mariadb103, mariadb-103


   --> Creating resources ...
       imagestreamtag.image.openshift.io "mariadb:10.3-el8" created
       deployment.apps "mariadb" created
       service "mariadb" created
   --> Success
       Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
        'oc expose service/mariadb'
       Run 'oc status' to view your app.
   ```

3. Check the status via ```oc status```:

   ```console
   > oc status
   In project my-first-project on server https://api.crc.testing:6443

   svc/mariadb - 10.217.5.164:3306
     deployment/mariadb deploys openshift/mariadb:10.3-el8
       deployment #2 running for 41 seconds - 0/1 pods
       deployment #1 deployed 42 seconds ago - 0/1 pods growing to 1


   1 info identified, use 'oc status --suggest' to see details.
   ```

4. First identify the name of the pod:

   ```console
   > oc get pods
   NAME                       READY   STATUS              RESTARTS   AGE
   mariadb-866498c658-b2qv5   0/1     ContainerCreating   0          58s

   > oc get pods
   NAME                       READY   STATUS    RESTARTS   AGE
   mariadb-866498c658-b2qv5   1/1     Running   0          3m8s
   ```

   Then use ```oc port-forward``` to reach the 3306 port of the container:

   ```console
   > oc port-forward mariadb-866498c658-b2qv5 3306:3306
   Forwarding from 127.0.0.1:3306 -> 3306
   Forwarding from [::1]:3306 -> 3306
   ```

5. Install MySQL client:

   ```console
   > yum -y install mariadb
   ```

   Query the local port:

   ```console
   > mysql --host=127.0.0.1 --port 3306 --user=user --password=pass --database=testdb
   Welcome to the MariaDB monitor.  Commands end with ; or \g.
   Your MySQL connection id is 6
   Server version: 5.7.21 MySQL Community Server (GPL)

   Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

   Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

   MySQL [testdb]>
   ```

6. Use ```oc delete``` to remove the project:

   ```console
   > oc delete project my-first-project
   project.project.openshift.io "my-first-project" deleted
   ```
