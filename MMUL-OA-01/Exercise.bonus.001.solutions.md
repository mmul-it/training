# Exercise Bonus 001 - Perform updates and rollback of a deployment - Solutions

---

1. Login as 'developer' and create the new 'testdeploy' project:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...
   
   > oc new-project testdeploy
   Now using project "testdeploy" on server "https://api.crc.testing:6443".
   ...
   ```

   Create the deployment and wait untile the pod is running:

   ```console
   > oc create deployment webserver --image=nginxinc/nginx-unprivileged:1.19-perl
   deployment.apps/webserver created
   
   > oc get pods
   NAME                        READY   STATUS                RESTARTS   AGE
   webserver-7cbfc8f97-68wv6   0/1     ContainerCreating     0          11s
   
   > oc get pods
   NAME                        READY   STATUS    RESTARTS   AGE
   webserver-7cbfc8f97-68wv6   1/1     Running   0          2m57s
   ```

2. Create the service for this deployment:

   ```console
   > oc expose deployment webserver --type="NodePort" --port=8080
   service/webserver exposed
   
   > oc get services
   NAME        TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
   webserver   NodePort   10.217.5.106   <none>        8080:31629/TCP   113s
   ```

   Create a route for accessing it outside of OCP:

   ```console
   > oc expose service webserver
   route.route.openshift.io/webserver exposed
   
   > oc get routes
   NAME        HOST/PORT                               PATH   SERVICES    PORT   TERMINATION   WILDCARD
   webserver   webserver-testdeploy.apps-crc.testing          webserver   8080                 None
   ```

   Try asking for an unavailable page to see the webserver version:

   ```console
   > curl http://webserver-testdeploy.apps-crc.testing/sourcesense
   <html>
   <head><title>404 Not Found</title></head>
   <body>
   <center><h1>404 Not Found</h1></center>
   <hr><center>nginx/1.19.10</center>
   </body>
   </html>
   ```

3. Update the nginx-unprivileged container image with the version '1.20-perl':

   ```console
   > oc set image deployment webserver nginx-unprivileged=nginxinc/nginx-unprivileged:1.20-perl
   deployment.apps/webserver image updated
   ```

   Follow the rollout status:

   ```console
   > oc rollout status deployment webserver
   Waiting for deployment "webserver" rollout to finish: 1 old replicas are pending termination...
   Waiting for deployment "webserver" rollout to finish: 1 old replicas are pending termination...
   deployment "webserver" successfully rolled out
   ```

   Test if the webserver reports the new version:

   ```console
   > curl http://webserver-testdeploy.apps-crc.testing/sourcesense
   <html>
   <head><title>404 Not Found</title></head>
   <body>
   <center><h1>404 Not Found</h1></center>
   <hr><center>nginx/1.20.1</center>
   </body>
   </html>
   ```

   Check ReplicaSets status:

   ```console
   > oc get replicasets
   NAME                  DESIRED   CURRENT   READY   AGE
   webserver-7cbfc8f97   0         0         0       9m34s
   webserver-d769ff897   1         1         1       2m50s
   ```

4. Update the nginx-unprivileged container image with the version '1.21-perl':

   ```console
> oc set image deployment webserver nginx-unprivileged=nginxinc/nginx-unprivileged:1.21-perl
deployment.apps/webserver image updated
   ```

   Follow again the rollout status:

   ```console
   > oc rollout status deployment webserver
   Waiting for deployment "webserver" rollout to finish: 1 old replicas are pending termination...
   Waiting for deployment "webserver" rollout to finish: 1 old replicas are pending termination...
   deployment "webserver" successfully rolled out
   ```

   Check if the webserver reports the new version:

   ```console
   > curl http://webserver-testdeploy.apps-crc.testing/sourcesense
   <html>
   <head><title>404 Not Found</title></head>
   <body>
   <center><h1>404 Not Found</h1></center>
   <hr><center>nginx/1.21.1</center>
   </body>
   </html>
   ```

5. Show available deployment rollout history:

   ```console
   > oc rollout history deployment webserver
   deployment.apps/webserver
   REVISION  CHANGE-CAUSE
   1         <none>
   2         <none>
   3         <none>
   ```

   We want to rollback our deployment to our first iteration:

   ```console
   > oc rollout undo deployment webserver --to-revision=1
   deployment.apps/webserver rolled back
   ```

   Check which version are now executed:

   ```console
   > curl http://webserver-testdeploy.apps-crc.testing/sourcesense
   <html>
   <head><title>404 Not Found</title></head>
   <body>
   <center><h1>404 Not Found</h1></center>
   <hr><center>nginx/1.19.10</center>
   </body>
   </html>
   ```

   Show the available rollout history again:

   ```console
   > oc rollout history deployment webserver
   deployment.apps/webserver
   REVISION  CHANGE-CAUSE
   2         <none>
   3         <none>
   4         <none>
   ```
