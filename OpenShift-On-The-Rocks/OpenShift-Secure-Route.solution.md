# Lab | Create a secure route

In this lab you will:

1. As `developer`, create a new project named `route-test` and deploy a new
   app named `testroute` based on the nginx container image.
2. Check the app status.
3. Create a key and a certificate to expose your site.
4. Define an **edge** Route named `nginx`. Let OpenShift generate the hostname
   by itself.
5. Test the secure connection via browser or curl.

## Solution

1. Become `developer`:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...
   ```

   And create `route-test` project:

   ```console
   > oc new-project route-test
   Now using project "route-test" on server "https://api.crc.testing:6443".
   ...
   ```

   To specifically use the `nginx` image you'll need the '--image=' switch:

   ```console
   > oc new-app --name=testroute --image=nginxinc/nginx-unprivileged
   --> Found container image 4cdc5dd (8 days old) from Docker Hub for "nginx"
   ...
   ```

2. Check the status:

   ```console
   > oc status
   svc/testroute - 10.217.4.202:8080
     deployment/testroute deploys istag/testroute:latest 
       deployment #2 running for 6 seconds - 1 pod
       deployment #1 deployed 7 seconds ago
   ```

3. Create a key and a certificate request:

   ```console
   > openssl genrsa -out example.key 2048
   ...

   > openssl req -new -key example.key -out example.csr -subj "/C=IT/ST=IT/L=Milan/O=Example/OU=IT/CN=nginx-route-test.apps-crc.testing"
   ...
   ```

   then sign the request with the key to generate your certificate:

   ```console
   > openssl x509 -req -days 366 -in example.csr -signkey example.key -out example.crt
   ```

4. Find the name of the app generated service:

   ```console
   > oc get services
   NAME        TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
   testroute   ClusterIP   10.217.5.6   <none>        80/TCP    30m
   ```

   then create an edge route using this information and the key/certificate pair
   just created:

   ```console
   > oc create route edge nginx --service=testroute --key=example.key --cert=example.crt
   route.route.openshift.io/nginx created
   ```

   then see the newly created rule:

   ```console
   > oc get routes
   NAME    HOST/PORT                           PATH   SERVICES    PORT     TERMINATION   WILDCARD
   nginx   nginx-route-test.apps-crc.testing          testroute   80-tcp   edge          None
   ```

5. Test the secure connection:

   ```console
   > curl -k -v https://nginx-route-test.apps-crc.testing
   ...
     * Server certificate:
     *  subject: C=IT; ST=IT; L=Milan; O=Example; OU=IT; CN=nginx-route-test.apps-crc.testing
     *  start date: Jul 15 13:23:39 2021 GMT
     *  expire date: Jul 16 13:23:39 2022 GMT
     *  issuer: C=IT; ST=IT; L=Milan; O=Example; OU=IT; CN=nginx-route-test.apps-crc.testing
     *  SSL certificate verify result: self signed certificate (18), continuing anyway.
   ...
                                                                  <h1>Welcome to nginx!</h1>
   ...
   ```

   Cleanup:

   ```console
   > oc delete project route-test
   project.project.openshift.io "route-test" deleted
   ```
