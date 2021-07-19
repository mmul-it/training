# Exercise 011 - Create a secure route - Solutions

---

1. Become 'developer':

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...
   ```

   And create 'route-test' project:

   ```console
   > oc new-project route-test
   Now using project "route-test" on server "https://api.crc.testing:6443".
   ...
   ```

   To specifically use the 'nginx' image from the 'docker-image' you'll need to
   use the '--docker-image=' switch:

   ```console
   > oc new-app --name=testroute --docker-image=nginx:latest
   --> Found container image 4cdc5dd (8 days old) from Docker Hub for "nginx"
   ...
   ```

2) Check the status:

   ```console
   > oc status
   ...
   svc/testroute - 10.217.5.6:80
     deployment/testroute deploys istag/testroute:latest
         deployment #3 running for about a minute - 1 pod
              deployment #2 deployed 6 minutes ago
                      deployment #1 deployed 6 minutes ago
   ```

   if you see the pod in CrashLoop status, remember that nginx image from Docker
   will require high permissions to run. So you need to assign the useroot
   serviceAccountName: to the application spec (see Exercise 009).

3) Create a key and a certificate request:

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

4) Find the name of the app generated service:

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

5) Test the secure connection:

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
