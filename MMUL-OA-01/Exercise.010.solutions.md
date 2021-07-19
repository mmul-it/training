# Exercise 010 - Exposing your application - Solutions

---

1. Login as 'developer' and create the new 'expose-test' project:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...

   > oc new-project expose-test
   Now using project "expose-test" on server "https://api.crc.testing:6443".
   ...
   ```

   Create the two applications:

   ```console
   > oc new-app mariadb MYSQL_USER=user MYSQL_PASSWORD=pass MYSQL_DATABASE=testdb -l db=mariadb
   --> Found image bde1f31 (3 weeks old) in image stream "openshift/mariadb" under tag "10.3-el8" for "mariadb"
   ...

   > oc new-app tomcat
   --> Found container image 36ef696 (12 days old) from Docker Hub for "tomcat"
   ...
   ```

2. Check the status of the various components:

   ```console
   > oc status
   In project expose-test on server https://api.crc.testing:6443

   svc/mariadb - 10.217.5.78:3306
     deployment/mariadb deploys openshift/mariadb:10.3-el8
       deployment #2 running for 4 minutes - 1 pod
       deployment #1 deployed 4 minutes ago

   svc/tomcat - 10.217.5.122:8080
     deployment/tomcat deploys istag/tomcat:latest
       deployment #2 running for 3 minutes - 1 pod
       deployment #1 deployed 3 minutes ago


   2 infos identified, use 'oc status --suggest' to see details.

   > oc get deployment
   NAME      READY   UP-TO-DATE   AVAILABLE   AGE
   mariadb   1/1     1            1           4m24s
   tomcat    1/1     1            1           3m39s

   > oc get pods
   NAME                       READY   STATUS    RESTARTS   AGE
   mariadb-6844d48bf6-wc66z   1/1     Running   0          4m35s
   tomcat-d7cdc4676-59f6h     1/1     Running   0          3m48s

   > oc get svc
   NAME      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
   mariadb   ClusterIP   10.217.5.78    <none>        3306/TCP   4m42s
   tomcat    ClusterIP   10.217.5.122   <none>        8080/TCP   3m57s
   ```

3. Use 'oc expose' to expose the services:

   ```console
   > oc expose svc/tomcat
   route.route.openshift.io/tomcat exposed

   > oc expose svc/mariadb
   route.route.openshift.io/mariadb exposed

   > oc status
   ...
   http://mariadb-expose-test.apps-crc.testing to pod port 3306-tcp (svc/mariadb)
     deployment/mariadb deploys openshift/mariadb:10.3-el8
       deployment #2 running for 5 minutes - 1 pod
       deployment #1 deployed 5 minutes ago

   http://tomcat-expose-test.apps-crc.testing to pod port 8080-tcp (svc/tomcat)
     deployment/tomcat deploys istag/tomcat:latest
       deployment #2 running for 4 minutes - 1 pod
       deployment #1 deployed 4 minutes ago
   ...
   ```

4. Using curl, let's check how the services answer:

   ```console
   > curl http://tomcat-expose-test.apps-crc.testing
   <!doctype html><html lang="en"><head><title>...<h3>Apache Tomcat/9.0.50</h3></body></html>

   > curl http://mariadb-expose-test.apps-crc.testing
   <html><body><h1>502 Bad Gateway</h1>
   The server returned an invalid or incomplete response.
   </body></html>
   ```

   The mariadb can't be reached by http, that is why we get '502 Bad Gateway', so
   it is possible to remove it:

   ```console
   > oc get route
   NAME      HOST/PORT                              PATH   SERVICES   PORT       TERMINATION   WILDCARD
   mariadb   mariadb-expose-test.apps-crc.testing          mariadb    3306-tcp                 None
   tomcat    tomcat-expose-test.apps-crc.testing           tomcat     8080-tcp                 None

   > oc delete route mariadb
   route.route.openshift.io "mariadb" deleted

   > oc get route
   NAME     HOST/PORT                             PATH   SERVICES   PORT       TERMINATION   WILDCARD
   tomcat   tomcat-expose-test.apps-crc.testing          tomcat     8080-tcp                 None
   ```

5. By deleting the project with 'oc delete project' everything will be wiped
as well:

   ```console
   > oc delete project expose-test
   project.project.openshift.io "expose-test" deleted
   ```