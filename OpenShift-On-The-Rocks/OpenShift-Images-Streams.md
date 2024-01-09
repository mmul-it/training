# Lab | Use ImageStreams to perform updates and rollback of a DeploymentConfig

In this lab you will:

1. As developer create a new project named `testdeploy`.
2. Create an ImageStream named `webserver`, and import as `webserver:1.19-perl`
   the image coming from `nginxinc/nginx-unprivileged:1.19-perl` into it,
   tagging it also `latest`.
3. Create and expose a `DeploymentConfig` by using `oc new-app` command with the
   specific `--as-deployment-config` option, naming it `webserver` and getting
   the image from the image stream `webserver:latest`.
4. Check the automatically created trigger inside the `DeploymentConfig` named
   `webserver`.
5. Import into the `webserver` ImageStream the `1.20-perl` image, tagging it as
   `latest`, and look if the trigger is executed.
6. Import into the `webserver` Image Stream the `1.21-perl` image, tagging also
   this new one as `latest`, and look if the trigger is executed.
7. Look at the rollout history and rollback the deployment its first iteration.

## Solution

1. Login as `developer` and create the new `testdeploy` project:

   ```console
   $ oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...

   $ oc new-project testdeploy
   Now using project "testdeploy" on server "https://api.crc.testing:6443".
   ...
   ```

2. Create the (empty) image stream named `webserver` that will be used for our
   deployment configuration:

   ```console
   $ oc create is webserver
   imagestream.image.openshift.io/webserver created

   $ oc get is
   NAME        IMAGE REPOSITORY                                                               TAGS      UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/testdeploy/webserver
   ```

   Now import into the newly created image stream the specific `1.19-perl`
   image from the public registry `nginxinc/nginx-unprivileged:1.19-perl`:

   ```console
   $ oc import-image webserver:1.19-perl --from=nginxinc/nginx-unprivileged:1.19-perl --confirm
   imagestream.image.openshift.io/webserver imported
   ...

   $ oc get is
   NAME        IMAGE REPOSITORY                                                               TAGS        UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/testdeploy/webserver   1.19-perl   5 seconds ago
   ```

   Now add the tag `latest` to the imported image so that it will be possible to
   refer to this image also by using the general `latest` version:

   ```console
   $ oc tag webserver:1.19-perl webserver:latest
   Tag webserver:latest set to webserver@sha256:8974116f08df4cbeb69bee35437675b225e745e67e6075f43523d9f8230a1191.

   $ oc get is
   NAME        IMAGE REPOSITORY                                                               TAGS               UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/testdeploy/webserver   latest,1.19-perl   3 seconds ago
   ```

3. When creating and exposing the new app we're going to use the
   `--as-deployment-config` option to force the creation of a deployment config
   component, the only one that supports triggers, using the `webserver` image
   stream with the `latest` version.
   Once pods will be deployed, we can verify the NGinx version using curl, as
   follows:

   ```console
   $ oc new-app --as-deployment-config --name=webserver --image-stream=webserver:latest
   --> Found image ee54951 (3 months old) in image stream "testdeploy/webserver" under tag "latest" for "webserver:latest"

   $ oc expose service webserver
   route.route.openshift.io/webserver exposed

   $ curl -s http://webserver-testdeploy.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.19.10</center>
   ```

4. The `oc new-app` commmand automatically creates a trigger based upon the image
   stream version:

   ```console
   $ oc get deploymentconfigs.apps.openshift.io webserver -o yaml
   ...
     triggers:
     - type: ConfigChange
     - imageChangeParams:
         automatic: true
         containerNames:
         - webserver
         from:
           kind: ImageStreamTag
           name: webserver:latest
           namespace: testdeploy
         lastTriggeredImage: nginxinc/nginx-unprivileged@sha256:8974116f08df4cbeb69bee35437675b225e745e67e6075f43523d9f8230a1191
       type: ImageChange
   ...
   ```

   This means that whenever `latest` will change a new deployment will be
   produced.

5. To import the `1.20-perl` release into the image stream the `oc import-image`
   command can be used as before:

   ```console
   $ oc import-image webserver:1.20-perl --from=nginxinc/nginx-unprivileged:1.20-perl --confirm
   imagestream.image.openshift.io/webserver imported
   ...
   ```

   Tag it as `latest`, looking at the deployment config for the triggered
   action:

   ```console
   $ oc tag webserver:1.20-perl webserver:latest
   Tag webserver:latest set to webserver@sha256:a6915075a63fc9da232500402f03268efb3b159e5882190a65090fe24510b3a3.

   $ oc status
   In project testdeploy on server https://api.crc.testing:6443

   http://webserver-testdeploy.apps-crc.testing to pod port 8080-tcp (svc/webserver)
     dc/webserver deploys istag/webserver:latest
       deployment #2 running for 9 seconds - 1 pod
       deployment #1 deployed 2 minutes ago
   4 infos identified, use 'oc status --suggest' to see details.

   $ curl -s http://webserver-testdeploy.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.20.1</center>
   ```

6. Apply the same process for the `1.21-perl` release:

   ```console
   $ oc import-image webserver:1.21-perl --from=nginxinc/nginx-unprivileged:1.21-perl --confirm
   imagestream.image.openshift.io/webserver imported

   $ oc tag webserver:1.21-perl webserver:latest
   Tag webserver:latest set to webserver@sha256:33aa22ba83302a9fb73b19a9fca8a4a143084e990e7340c6b88b7318e6a72853.

   $ oc status
   In project testdeploy on server https://api.crc.testing:6443

   http://webserver-testdeploy.apps-crc.testing to pod port 8080-tcp (svc/webserver)
     dc/webserver deploys istag/webserver:latest
       deployment #3 deployed 14 seconds ago - 1 pod
       deployment #2 deployed about a minute ago
       deployment #1 deployed 3 minutes ago
   5 infos identified, use 'oc status --suggest' to see details.

   $ curl -s http://webserver-testdeploy.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.21.1</center>
   ```

7. Now look at the rollout history:

   ```console
   $ oc rollout history deploymentconfig webserver
   deploymentconfigs "webserver"
   REVISION    STATUS        CAUSE
   1        Complete    config change
   2        Complete    image change
   3        Complete    image change
   ```

   And move back to the initial revision, checking the service will move back
   to the `1.19` release:

   ```console
   $ oc rollout undo dc/webserver --to-revision=1
   deploymentconfig.apps.openshift.io/webserver rolled back

   $ oc rollout history deploymentconfig webserver
   deploymentconfigs "webserver"
   REVISION    STATUS        CAUSE
   1        Complete    config change
   2        Complete    image change
   3        Complete    image change
   4        Complete    image change

   $ curl -s http://webserver-testdeploy.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.19.10</center>
   ```

   For each `undo` action a new revision will be produced, so to keep track in
   the history.

   **IMPORTANT NOTE!** Any image triggers present in the rolled back
   configuration will be disabled with a warning. This is to help prevent
   your rolled back deployment from being replaced by a triggered deployment
   soon after your rollback.
   To re-enable the triggers, use the `oc set triggers --auto` command.
