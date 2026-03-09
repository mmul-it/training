# Lab | Use ImageStreams to perform updates and rollback of a Deployment

In this lab you will:

1. As developer create a new project named `is-test`.
2. Create an ImageStream named `webserver`, and import as `webserver:1.19-perl`
   the image coming from `docker.io/nginxinc/nginx-unprivileged:1.19-perl` into
   it, tagging it also `latest`.
3. Create and expose a `Deployment` by using `oc new-app` naming it `webserver`
   and getting the image from the image stream `webserver:latest`.
4. Check the automatically created trigger inside the `Deployment` named
   `webserver`.
5. Import into the `webserver` ImageStream the `1.21-perl` image, tagging it as
   `latest`, and look if the trigger is executed.
6. Import into the `webserver` Image Stream the `1.24-perl` image, tagging also
   this new one as `latest`, and look if the trigger is executed.
7. Look at the rollout history and understand why a rollback to the previous 2
   revision will have no results. Fix things so that a rollback to revision 2
   will get the deployment exactly to the `1.19-perl` image release.

## Solution

1. Login as `developer` and create the new `is-test` project:

   ```console
   $ oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...

   $ oc new-project is-test
   Now using project "is-test" on server "https://api.crc.testing:6443".
   ...
   ```

2. Create the (empty) image stream named `webserver` that will be used for our
   deployment configuration:

   ```console
   $ oc create is webserver
   imagestream.image.openshift.io/webserver created

   $ oc get is
   NAME        IMAGE REPOSITORY                                                               TAGS      UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/is-test/webserver
   ```

   Now import into the newly created image stream the specific `1.19-perl`
   image from the public registry `docker.io/nginxinc/nginx-unprivileged:1.19-perl`:

   ```console
   $ oc import-image webserver:1.19-perl --from=docker.io/nginxinc/nginx-unprivileged:1.19-perl --confirm
   imagestream.image.openshift.io/webserver imported
   ...

   $ oc get is
   NAME        IMAGE REPOSITORY                                                               TAGS        UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/is-test/webserver   1.19-perl   5 seconds ago
   ```

   Now add the tag `latest` to the imported image so that it will be possible to
   refer to this image also by using the general `latest` version:

   ```console
   $ oc tag webserver:1.19-perl webserver:latest
   Tag webserver:latest set to webserver@sha256:8974116f08df4cbeb69bee35437675b225e745e67e6075f43523d9f8230a1191.

   $ oc get is
   NAME        IMAGE REPOSITORY                                                               TAGS               UPDATED
   webserver   default-route-openshift-image-registry.apps-crc.testing/is-test/webserver   latest,1.19-perl   3 seconds ago
   ```

3. By creating and exposing the new app we're going to get a deployment
   component, using the `webserver` image stream with the `latest` version.
   Once pods will be deployed, we can verify the NGinx version using curl, as
   follows:

   ```console
   $ oc new-app --name=webserver --image-stream=webserver:latest
   --> Found image ee54951 (3 months old) in image stream "is-test/webserver" under tag "latest" for "webserver:latest"

   $ oc expose service webserver
   route.route.openshift.io/webserver exposed

   $ curl -s http://webserver-is-test.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.19.10</center>
   ```

   It is possible to keep track of the deployment status, by setting the
   `change-cause` of the deployment:

   ```console
   $ oc annotate deployment/webserver kubernetes.io/change-cause="ImageStream 'webserver' set to 1.19-perl" --overwrite
   deployment.apps/webserver annotated

   $ oc rollout history deployment
   deployment.apps/webserver
   REVISION  CHANGE-CAUSE
   1         <none>
   2         ImageStream 'webserver' set to 1.19-perl
   ```

4. The `oc new-app` commmand automatically creates a trigger based upon the
   image stream version:

   ```console
   $ oc get deployment webserver -o jsonpath='{.metadata.annotations.image\.openshift\.io/triggers}' | jq
   [
     {
       "from": {
         "kind": "ImageStreamTag",
         "name": "webserver:latest",
         "namespace": "is-test"
       },
       "fieldPath": "spec.template.spec.containers[?(@.name==\"webserver\")].image"
     }
   ]
   ```

   This means that whenever `latest` will change a new deployment will be
   produced.

5. To import the `1.21-perl` release into the image stream the `oc import-image`
   command can be used as before:

   ```console
   $ oc import-image webserver:1.21-perl --from=docker.io/nginxinc/nginx-unprivileged:1.21-perl --confirm
   imagestream.image.openshift.io/webserver imported
   ...
   ```

   Tag it as `latest`, looking at the deployment config for the triggered
   action:

   ```console
   $ oc tag webserver:1.21-perl webserver:latest
   Tag webserver:latest set to webserver@sha256:a6915075a63fc9da232500402f03268efb3b159e5882190a65090fe24510b3a3.

   $ oc status
   In project is-test on server https://api.crc.testing:6443

   http://webserver-is-test.apps-crc.testing to pod port 8080-tcp (svc/webserver)
     dc/webserver deploys istag/webserver:latest
       deployment #2 running for 9 seconds - 1 pod
       deployment #1 deployed 2 minutes ago
   4 infos identified, use 'oc status --suggest' to see details.

   $ curl -s http://webserver-is-test.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.21.6</center>
   ```

   Again, let's keep track of the image change:

   ```console
   $ oc annotate deployment/webserver kubernetes.io/change-cause="ImageStream 'webserver' set to 1.21-perl" --overwrite
   deployment.apps/webserver annotated

   $ oc rollout history deployment
   deployment.apps/webserver
   REVISION  CHANGE-CAUSE
   1         <none>
   2         ImageStream 'webserver' set to 1.19-perl
   3         ImageStream 'webserver' set to 1.21-perl
   ```

6. Apply the same process for the `1.24-perl` release:

   ```console
   $ oc import-image webserver:1.24-perl --from=docker.io/nginxinc/nginx-unprivileged:1.24-perl --confirm
   imagestream.image.openshift.io/webserver imported

   $ oc tag webserver:1.24-perl webserver:latest
   Tag webserver:latest set to webserver@sha256:33aa22ba83302a9fb73b19a9fca8a4a143084e990e7340c6b88b7318e6a72853.

   $ oc status
   In project is-test on server https://api.crc.testing:6443

   http://webserver-is-test.apps-crc.testing to pod port 8080-tcp (svc/webserver)
     dc/webserver deploys istag/webserver:latest
       deployment #3 deployed 14 seconds ago - 1 pod
       deployment #2 deployed about a minute ago
       deployment #1 deployed 3 minutes ago
   5 infos identified, use 'oc status --suggest' to see details.

   $ curl -s http://webserver-is-test.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.24.0</center>
   ```

   Again, let's keep track of the change:

   ```console
   $ oc annotate deployment/webserver kubernetes.io/change-cause="ImageStream 'webserver' set to 1.24-perl" --overwrite
   deployment.apps/webserver annotated

   $ oc rollout history deployment
   deployment.apps/webserver
   REVISION  CHANGE-CAUSE
   1         <none>
   2         ImageStream 'webserver' set to 1.19-perl
   3         ImageStream 'webserver' set to 1.21-perl
   4         ImageStream 'webserver' set to 1.24-perl
   ```

7. By Looking at the rollout history:

   ```console
   $ oc rollout history deployment webserver
   deployment.apps/webserver
   REVISION  CHANGE-CAUSE
   1         <none>
   2         ImageStream 'webserver' set to 1.19-perl
   3         ImageStream 'webserver' set to 1.21-perl
   4         ImageStream 'webserver' set to 1.24-perl
   ```

   It should be possible to rollback the deployment to the revision 2, by using
   the `oc rollout undo deployment webserver --to-revision=2` command.

   The problem is that each one of the deployment configurations is pointing the
   `webserver:latest` image stream, so the rollback will not have any result,
   and instead add confusion:

   ```console
   $ oc rollout undo deployment webserver --to-revision=2
   deployment.apps/webserver rolled back

   $ oc rollout history deployment
   deployment.apps/webserver
   REVISION  CHANGE-CAUSE
   1         <none>
   3         ImageStream 'webserver' set to 1.21-perl
   5         ImageStream 'webserver' set to 1.19-perl
   6         ImageStream 'webserver' set to 1.19-perl

   $ curl -s http://webserver-is-test.apps-crc.testing/unavailable | grep nginx
   <hr><center>nginx/1.24.0</center>
   ```

   The reason for this is simple and is dictated by the deployment trigger,
   which looks like this:

   ```console
   $ oc get deployment webserver -o jsonpath='{.metadata.annotations.image\.openshift\.io/triggers}' | jq
   [
    {
      "from": {
        "kind": "ImageStreamTag",
        "name": "webserver:latest",
        "namespace": "is-test"
      },
      "fieldPath": "spec.template.spec.containers[?(@.name==\"webserver\")].image"
    }
   ]
   ```

   So when `latest` changes, a new deployment occurs. Each deployment records
   the hash of the image used by the containers, which in our case is:

   - **TAG**: `1.19-perl`
     - _DIGEST_: `sha256:8974116f08df4cbeb69bee35437675b225e745e67e6075f43523d9f8230a1191`
     - _Revision_: `2`
   - **TAG**: `1.21-perl`
     - _DIGEST_: `sha256:76c6749c04e02d48a2427ffbe4ef5ff12ee7ad3522a8c009f4e003c0361db6cf`
     - _Revision_: `3`
   - **TAG**: `1.24-perl`
     - _DIGEST_: `sha256:28f1ec6894009918189eee10bed493f1df920dd87f2c44739927004673b16e4c`
     - _Revision_: `4` (and latest)

   When rollback occurs, the following sequence happens:

   1. OpenShift creates a new deployment whose image points to the `1.19-perl`
      hash (this becomes Revision 5).
   2. The deployment trigger detects that the current deployment's hash is
      different from latest (which still points to `1.24-perl`) and therefore
      triggers a new deployment (Revision 6) that points back to latest.
   3. Only by resetting the ImageStream's latest tag to point to `1.19-perl`
      can we achieve a realistic rollback.

   The solution described above is impractical and difficult to implement in the
   real world. That's why I've corrected the lab so that now the rollback
   sequence (remember, this is a manual operation) follows this process:

   1. Manually delete the latest tag:

      ```console
      $ oc tag --delete webserver:latest
      Deleted tag is-test/webserver:latest.
      ```

   2. Perform the rollback operation:

      ```console
      $ oc rollout undo deployment webserver --to-revision=2
      deployment.apps/webserver rolled back
      ```

   3. OpenShift doesn't trigger anything since latest doesn't exist. It becomes
      the user's choice to trigger manually, for example with:

      ```console
      $ oc tag webserver:1.19-perl webserver:latest
      Tag webserver:latest set to webserver@sha256:8974116f08df4cbeb69bee35437675b225e745e67e6075f43523d9f8230a1191.
      ```

   This approach makes the workflow much more comprehensible and applicable to
   a production context because:

   - It's explicit: The user has full control over when and how the latest tag
     is updated.
   - It's predictable: No automatic triggers cause unexpected behavior.
   - It mirrors real-world practices: In production, updating the "latest" tag
     is typically a deliberate action, often part of a CI/CD pipeline.

   This manual workflow gives you true rollback capability—when you roll back to
   revision 2, you actually stay with that version until you explicitly decide
   to update the latest tag again.
