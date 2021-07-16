# Exercise 015 - Deploy some applications from git and from Docker images - Solutions

_1) As 'developer' create a new 'testdeploy' project_

Login as developer on the cluster:

```
> oc login -u developer
Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
```

Then create the new project:

```
> oc new-project testdeploy
Now using project "testdeploy" on server "https://api.crc.testing:6443".
```

_2) Create a new app from https://github.com/mmul-it/docker/ repository. You
   must specify the s2i-php-helloworld directory as the context dir._

This can be done with a single new-app command. You must specify the name, the
git repository and the context-dir where the application code is available.

```
> oc new-app --name=myapp https://github.com/mmul-it/docker/ --context-dir=s2i-php-helloworld
--> Found image b416a19 (3 weeks old) in image stream "openshift/php" under tag "7.4-ubi8" for "php"
...
--> Success
    Build scheduled, use 'oc logs -f buildconfig/myapp' to track its progress.
    Application is not exposed. You can expose services to the outside world by executing one or more of the commands below:
     'oc expose service/myapp'
    Run 'oc status' to view your app.
```

You can now see your app status:

```
> oc status
In project testdeploy on server https://api.crc.testing:6443

svc/myapp - 10.217.4.73 ports 8080, 8443
  deployment/myapp deploys istag/myapp:latest <-
    bc/myapp source builds https://github.com/mmul-it/docker/ on openshift/php:7.4-ubi8
    deployment #2 running for 10 minutes - 1 pod
    deployment #1 deployed 12 minutes ago
```

As you can see the new-app is composed by a Service, a Deployment, a
BuildConfig and two pods.

```
> oc get pods
NAME                     READY   STATUS      RESTARTS   AGE
myapp-1-build            0/1     Completed   0          14m
myapp-7687d69fdf-9n9jt   1/1     Running     0          12m
```

one pod is used for the build process, the other contains the resulting
container.

_3) Check the progress of the deployment._

You can check any time the progress of the building process by looking at the
logs of the BuildConfig resource:

```
> oc logs -f buildconfig/myapp
...
Successfully pushed image-registry.openshift-image-registry.svc:5000/testdeploy/myapp@sha256:00b94db50f561b92723a3635300a0f580762c159d665ca6262a3851539f77bf5
Push successful
```

_4) Expose and test the deployed application._

You can now use the "oc expose" command to make the application available
outside the cluster:

```
> oc expose svc/myapp
route.route.openshift.io/myapp exposed

> oc get routes
NAME    HOST/PORT                           PATH   SERVICES   PORT       TERMINATION   WILDCARD
myapp   myapp-testdeploy.apps-crc.testing          myapp      8080-tcp                 None
```

And test the application:

```
> curl http://myapp-testdeploy.apps-crc.testing ; echo
Welcome in MMUL!
```

_5) Clean everything._

Remove the application can be done in two passages. First of all remove the
application service and route:

```
> oc delete route/myapp service/myapp
route.route.openshift.io "myapp" deleted
service "myapp" deleted
```

Then you can delete the Deployment and the BuildConfig resources. This will
delete also the two pods.

```
> oc delete deployment/myapp buildconfig/myapp
deployment.apps "myapp" deleted
buildconfig.build.openshift.io "myapp" deleted

> oc get pods
NAME                     READY   STATUS        RESTARTS   AGE
myapp-1-build            0/1     Completed     0          20m
myapp-7687d69fdf-9n9jt   0/1     Terminating   0          18m

> oc get pods
No resources found in testdeploy namespace.
```

_6) Create a new app from the nginx official Docker image._

Creating a new app from a Docker image it's easy as passing the image name
to the oc new-app command:

```
> oc new-app nginx
--> Found image 3f3b9d2 (3 weeks old) in image stream "openshift/nginx" under tag "1.18-ubi8" for "nginx"
...
--> Success
...
```

Then you can check what is created:

```
> oc status
...
svc/nginx - 10.217.4.136 ports 8080, 8443
  deployment/nginx deploys openshift/nginx:1.18-ubi8
    deployment #2 running for 27 seconds - 0/1 pods
    deployment #1 deployed 29 seconds ago - 0/1 pods growing to 1
```

As you can see, creating an app from a Docker image doesn't require to build
anything, so the BuildConfig wasn't create.

_7) Expose and test the deployed application._

As before, expose the application by using the Service name:

```
> oc expose service nginx
route.route.openshift.io/nginx exposed

> oc get routes
NAME    HOST/PORT                           PATH   SERVICES   PORT       TERMINATION   WILDCARD
nginx   nginx-testdeploy.apps-crc.testing          nginx      8080-tcp                 None
```

Then curl the provided host to check the app:

```
> curl http://nginx-testdeploy.apps-crc.testing
...
<h1>Welcome to nginx!</h1>
...
```

_8) Clean everything._

Clean the route and services:

```
> oc delete route/nginx service/nginx
route.route.openshift.io "nginx" deleted
service "nginx" deleted
```

This time you can just delete the Deployment, so it will delete the created
pod also:

```
> oc delete deployment nginx
deployment.apps "nginx" deleted

> oc get pods
NAME                   READY   STATUS        RESTARTS   AGE
nginx-54bcd565-mx9zq   0/1     Terminating   0          4m39s

> oc get pods
No resources found in testdeploy namespace.
```
