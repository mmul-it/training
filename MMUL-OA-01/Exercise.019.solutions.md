# Exercise 019 - Create a custom template - Solutions

_1) Login as kubeadmin._

Join the cluster as kubeadmin user:

```
> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
```

_2) Starting from nginx-example template, create a yaml file for your new
   simple-nginx template._

Find the template to use as a starting point:

```
> oc get templates | grep nginx
nginx-example                                   An example Nginx HTTP server and a reverse proxy (nginx) application that ser...   10 (3 blank)      5
```

from that we can generate our yml file:

```
> oc get template nginx-example -o yaml > my-simple-nginx-template.yml
```

_3) Customize the simple-nginx.yml template definition._

Edit the my-simple-nginx-template.yml file and:

- Replace all occurrence of "nginx-example" with "simple-nginx"
- In the parameters section, add a parameter named REPLICAS with proper
  descriptions and a default vault of 1:

  ```
  - description: How many replicas of nginx you need.
    displayName: Nginx Replicas
	value: "1"
	name: REPLICAS
  ```

- Replace the static replicas value in the DeploymentConfig specs twith the
  parameter:

  ```
  replicas: ${{REPLICAS}}
  ```

You are now done. Your simple-nginx template have the same nginx-example
functionalities with the additional capability of specifing the replicas at
creation time.

_4) Create the template on the cluster._

Now you can define the new template in your cluster:

```
> oc create -f my-simple-nginx-template.yml
template.template.openshift.io/simple-nginx created
```

_5) Deploy a new app from this template._

Using your template is now possibile via the new-app command.

```
> oc new-app -p REPLICAS=2 simple-nginx
--> Deploying template "openshift/simple-nginx" to project openshift
...
--> Success
    Access your application via route 'simple-nginx-openshift.apps-crc.testing'
    Build scheduled, use 'oc logs -f buildconfig/simple-nginx' to track its progress.
    Run 'oc status' to view your app.
```

wait for the build to complete:

```
> oc logs -f buildconfig/simple-nginx
...
Successfully pushed image-registry.openshift-image-registry.svc:5000/openshift/simple-nginx@sha256:c6ed5fd3e365a635d0a8fe95e7a99cba6faf0ff7b473bd1acbc6587f8e07e0b3
Push successful
```

You can now see if your parameter works:

```
> oc status
...
http://simple-nginx-openshift.apps-crc.testing (svc/simple-nginx)
  dc/simple-nginx deploys istag/simple-nginx:latest <-
      bc/simple-nginx source builds https://github.com/sclorg/nginx-ex.git on istag/nginx:1.16-el8
	  deployment #1 deployed 38 seconds ago - 2 pods
```
