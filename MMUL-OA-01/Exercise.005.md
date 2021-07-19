# Exercise 005 - Customize a DeploymentConfig on OpenShift

1) Create a yaml or json file containing DeploymentConfig specifications. You
   can obtain a prepared yaml to explore use oc-new app with yaml output:

     oc new-app mariadb MYSQL_USER=user MYSQL_PASSWORD=pass MYSQL_DATABASE=testdb -l db=mariadb -o yaml > dc-mariadb.yaml

2) Explore the yaml: you can customize it before creating the resources on
   OpenShift.
   There are 3 different resources defined in this yaml:
   - ImageStreamTag: this resource provides a metod to keep an image in the
     OpenShift internal registry synced with an external registry;
   - DeploymentConfig: here the DeploymentConfig which keep informations about
     how Pods are composed, how many replicas, and when to react to changes;
   - Service: a method to expose our applications outside the OpenShift cluster.
     We will explore Services in further chapters;

3) Customize the DeploymentConfig resource to add a label "zone: dmz" and ensure
   at least 2 replicas of the Pods. Also remove the Service part;

4) Create the resources on your OpenShift cluster with oc create;

5) Observe the results;

6) Delete all the resources using the specific tag "zone: dmz" created above;
