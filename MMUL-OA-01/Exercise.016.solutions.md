# Exercise 016 - Create an ImageStream, deploy and expose an application - Solutions

---

1. Login to the cluster:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...
   ```

   Create a new project:

   ```console
   > oc new-project test-image-streams
   Now using project "test-image-streams" on server "https://api.crc.testing:6443".
   ...
   ```

   Check if there is any available ImageStreams

   ```console
   > oc get is
   No resources found in test-image-streams namespace.
   ```

2. Become the kubeadmin user:

   ```console
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ```

   Create the yaml:

   ```console
   > cat webserver-is.yml
   ```

   ```yaml
   apiVersion: image.openshift.io/v1
   kind: ImageStream
   metadata:
     name: webserver
   spec:
     lookupPolicy:
       local: false
     tags:
       - from:
           kind: DockerImage
           name: nginxinc/nginx-unprivileged:stable
         generation: null
         importPolicy: {}
         name: latest
   ```

   Create the ImageStream resource on the cluster:

   ```console
   > oc create -f webserver-is.yml
   imagestream.image.openshift.io/webserver created
   ```

   Check if available:

   ```console
   > oc get is
   NAME        IMAGE REPOSITORY                                                                       TAGS     UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/test-image-streams/webserver   latest   7 seconds ago
   ```

   Now you can find the expected images in the list of available images:

   ```console
   > oc get image | grep unpriv
   sha256:c452614d70306cb43310a89a5b3004c29b4c6fa702ee1090d03d2b6ab9294a35   nginxinc/nginx-unprivileged@sha256:c452614d70306cb43310a89a5b3004c29b4c6fa702ee1090d03d2b6ab9294a35
   ```

3. Log back as developer:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ```

   Check if the ImageStream is available:

   ```console
   > oc get is
   NAME        IMAGE REPOSITORY                                                                       TAGS     UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/test-image-streams/webserver   latest   45 seconds ago
   ```

4. Deploy a new app from this ImageStream:

   ```console
   > oc new-app --image-stream=webserver
   --> Found image e2328fa (2 weeks old) in image stream "test-image-streams/webserver" under tag "latest" for "webserver"
   
   
   --> Creating resources ...
       deployment.apps "webserver" created
       service "webserver" created
   --> Success
       Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
        'oc expose service/webserver'
       Run 'oc status' to view your app.
   ```

   Expose the application outside the cluster:

   ```console
   > oc expose service webserver
   route.route.openshift.io/webserver exposed
   
   > oc get routes
   NAME        HOST/PORT                                       PATH   SERVICES    PORT       TERMINATION   WILDCARD
   webserver   webserver-test-image-streams.apps-crc.testing          webserver   8080-tcp                 None
   ```

   Check if it is the expected version:

   ```console
   > curl http://webserver-test-image-streams.apps-crc.testing/sourcesense
   ...
   <hr><center>nginx/1.20.1</center>
   ...
   ```
