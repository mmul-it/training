# Lab | Create a custom template

In this lab you will:

1. Login as `kubeadmin`.
2. Starting from `nginx-example` template, create a yaml file for your new
   `simple-nginx` template.
3. Customize the `simple-nginx.yml` template definition by:
   - Replacing all occurrence of `nginx-example` with `simple-nginx`
   - Create a new parameter named `REPLICAS` that will manage the number of
     replicas inside the `Deployment` specs.
4. Create the template on the cluster.
5. Deploy a new app from this template.

## Solution

1. Join the cluster as `kubeadmin` user:

   ```console
   $ oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ```

2. Find the template to use as a starting point:

   ```console
   $ oc --namespace openshift get templates | grep nginx
   openshift    nginx-example    An example Nginx HTTP server and a reverse proxy (nginx) application that ser...   10 (3 blank)      5
   ```

   From which we can generate our yml file:

   ```console
   $ oc --namespace openshift get template nginx-example -o yaml > my-simple-nginx-template.yml
   (no output)
   ```

3. Edit the `my-simple-nginx-template.yml` file and:

   - Replace all occurrence of "nginx-example" with "simple-nginx"
   - In the parameters section, add a parameter named REPLICAS with proper
     descriptions and a default value of 1:

     ```yaml
     - description: How many replicas of nginx you need.
       displayName: Nginx Replicas
       value: "1"
       name: REPLICAS
     ```

   - Replace the static replicas value in the Deployment specs with the
     parameter:

     ```yaml
     replicas: ${{REPLICAS}}
     ```

   You are now done. Your simple-nginx template have the same nginx-example
   functionalities with the additional capability of specifing the replicas at
   creation time.

4. Now you can define the new template in your cluster:

   ```console
   $ oc create -f my-simple-nginx-template.yml
   template.template.openshift.io/simple-nginx created
   ```

5. As `developer` using your template is now possibile via the `oc new-app`
   command:

   ```console
   $ oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...

   $ oc new-project template-test
   Now using project "template-test" on server "https://api.crc.testing:6443".
   ...

   $ oc new-app -p REPLICAS=2 -p NGINX_VERSION=1.20-ubi9 simple-nginx
   --> Deploying template "openshift/simple-nginx" to project openshift
   ...
   --> Success
       Access your application via route 'simple-nginx-openshift.apps-crc.testing'
       Build scheduled, use 'oc logs -f buildconfig/simple-nginx' to track its progress.
       Run 'oc status' to view your app.
   ```

   Wait for the build to complete:

   ```console
   $ oc logs -f buildconfig/simple-nginx
   ...
   Successfully pushed image-registry.openshift-image-registry.svc:5000/openshift/simple-nginx@sha256:c6ed5fd3e365a635d0a8fe95e7a99cba6faf0ff7b473bd1acbc6587f8e07e0b3
   Push successful
   ```

   You can now see if your parameter works:

   ```console
   $ oc status
   ...
   http://simple-nginx-openshift.apps-crc.testing (svc/simple-nginx)
     dc/simple-nginx deploys istag/simple-nginx:latest <-
         bc/simple-nginx source builds https://github.com/sclorg/nginx-ex.git on istag/nginx:1.20-ubi9
         deployment #1 deployed 38 seconds ago - 2 pods
   ```

   Cleanup:

   ```console
   $ oc delete project template-test
   project.project.openshift.io "template-test" deleted
   ```
