# Exercise 016 - Create an ImageStream for nginx:alpine and verify available images - Solutions

---

1. Login to the cluster:

   ```console
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ```

   Check if there is an nginx ImageStream and an nginx:alpine image

   ```console
   > oc get is
   No resources found in testdeploy namespace.

   > oc get images | grep nginx
   sha256:1fdc4d81415e4750f8e645ccb07470ea2719b041b3cfa165e94c57a617f56585   registry.redhat.io/ubi8/nginx-118@sha256:1fdc4d81415e4750f8e645ccb07470ea2719b041b3cfa165e94c57a617f56585
   sha256:3b46c4749a6b155e2d4bc0f7a83706e70fdac9884080cc785716ea10b1d19cf0   registry.redhat.io/rhscl/nginx-116-rhel7@sha256:3b46c4749a6b155e2d4bc0f7a83706e70fdac9884080cc785716ea10b1d19cf0
   sha256:97cfbb52ae49f8946f262d3cc5b5df05b067510c16e9fd7c905e44bfa113ed35   registry.redhat.io/rhel8/nginx-116@sha256:97cfbb52ae49f8946f262d3cc5b5df05b067510c16e9fd7c905e44bfa113ed35
   sha256:a607acf93a1c532cef8d36f84ddd07ca782821cc80eac57b2bceb0d142d02d50   registry.redhat.io/ubi7/nginx-118@sha256:a607acf93a1c532cef8d36f84ddd07ca782821cc80eac57b2bceb0d142d02d50
   sha256:c9e035d14cc8681307275eb62a2b2a054048121941ba70e68e1c6ac89dc875ed   registry.redhat.io/rhel8/nginx-114@sha256:c9e035d14cc8681307275eb62a2b2a054048121941ba70e68e1c6ac89dc875ed
   ```

   There are some provided by RedHat for specific nginx version, but nothing for
   nginx:alpine offical image.

2. Write the yaml:

   ```console
   > cat nginx-is.yml
   ```

   ```yaml
   apiVersion: image.openshift.io/v1
   kind: ImageStream
   metadata:
     name: nginx
   spec:
     lookupPolicy:
       local: false
     tags:
       - from:
           kind: DockerImage
           name: nginx:alpine
         generation: null
         importPolicy: {}
         name: alpine
   ```

3. You can now create the ImageStream resource on the cluster:

   ```console
   > oc create -f nginx-is.yml
   imagestream.image.openshift.io/nginx created
   ```

   Check if available:

   ```console
   > oc get is
   NAME    IMAGE REPOSITORY                                                           TAGS     UPDATED
   nginx   default-route-openshift-image-registry.apps-crc.testing/testdeploy/nginx   alpine   30 seconds ago
   ```

   Now you can find the expected images in the list of available images:

   ```console
   > oc get image | grep nginx
   ...
   sha256:c35699d53f03ff9024ce2c8f6730567f183a15cc27b24453c5d90f0e7542daea   nginx@sha256:c35699d53f03ff9024ce2c8f6730567f183a15cc27b24453c5d90f0e7542daea
   ...
   ```
