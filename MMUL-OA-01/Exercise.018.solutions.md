# Exercise 018 - Scale-up, scale-down and configure autoscaling - Solutions

_1) Login as developer and create a new project._

Login as the developer user:

```
> oc login -u developer
Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
```

then create a new project:

```
> oc new-project testscale
Now using project "testscale" on server "https://api.crc.testing:6443".
```

_2) Deploy a new application named scale-docker-app based on the context dir
   s2i-php-helloworld in the git repository https://github.com/mmul-it/docker._

You can do that by using the new-app command:

```
> oc new-app --name=scale-docker-app https://github.com/mmul-it/docker --context-dir=s2i-php-helloworld
--> Found image b416a19 (3 weeks old) in image stream "openshift/php" under tag "7.4-ubi8" for "php"
...
```

then follow the build with:

```
> oc logs -f buildconfig/scale-docker-app
...
Successfully pushed image-registry.openshift-image-registry.svc:5000/testscale/scale-docker-app@sha256:dce19687cf5d926b1178e6ed3ddd8d312a13c995d5590761ed77dd7e13ea871b
Push successful
```

You can see there is a pod running the app now:

```
> oc get pods
NAME                                READY   STATUS      RESTARTS   AGE
scale-docker-app-1-build            0/1     Completed   0          2m38s
scale-docker-app-5b7ccb8dd5-qdz5c   1/1     Running     0          17s
```

_3) Check the ReplicaSet and see if requirements are met._

Obtaining a list of ReplicaSet:

```
> oc get rs
NAME                          DESIRED   CURRENT   READY   AGE
scale-docker-app-5b7ccb8dd5   1         1         1       72s
```

then see the ReplicaSet specification:

```
> oc describe rs scale-docker-app-5b7ccb8dd5
...
Replicas:       1 current / 1 desired
Pods Status:    1 Running / 0 Waiting / 0 Succeeded / 0 Failed
...
```

requisites are met.

_4) Scale the application up to 3 replicas. Check changes in the ReplicaSet and
   in the running pods._

Just do it with one command:

```
> oc scale --replicas=3 deployment scale-docker-app
deployment.apps/scale-docker-app scaled
```

if you quickly check again the ReplicaSet you can see the current status:

```
> oc describe rs scale-docker-app-5b7ccb8dd5
...
Replicas:       3 current / 3 desired
Pods Status:    1 Running / 2 Waiting / 0 Succeeded / 0 Failed
...
```

after few moments everything is scaled:

```
> oc describe rs scale-docker-app-5b7ccb8dd5
...
Replicas:       3 current / 3 desired
Pods Status:    3 Running / 0 Waiting / 0 Succeeded / 0 Failed
...
```

There are more pods now:

```
oc get pods
NAME                                READY   STATUS      RESTARTS   AGE
scale-docker-app-1-build            0/1     Completed   0          8m45s
scale-docker-app-5b7ccb8dd5-gn6kn   1/1     Running     0          3m8s
scale-docker-app-5b7ccb8dd5-khzkh   1/1     Running     0          3m8s
scale-docker-app-5b7ccb8dd5-qdz5c   1/1     Running     0          6m24s
``` 

_5) Scale down the application to 1 replica. Check and see when the operation
   ends._

```
> oc scale --replicas=1 deployment scale-docker-app
deployment.apps/scale-docker-app scaled
```

quickly, the replicas scale down to 1:

```
> oc get rs
NAME                          DESIRED   CURRENT   READY   AGE
scale-docker-app-5b7ccb8dd5   1         1         1       8m11s

> oc get pods
NAME                                READY   STATUS      RESTARTS   AGE
scale-docker-app-1-build            0/1     Completed   0          10m
scale-docker-app-5b7ccb8dd5-qdz5c   1/1     Running     0          8m25s
```

_6) Configure autoscaling on this application with a minumum of 1 pod, a
   maximum of 3 pods based on a CPU load of 50%. Then check if everything
   changed as expected._

Also autoscaling can be done with a single command:

```
> oc autoscale deployment scale-docker-app --min 1 --max 3 --cpu-percent=50
horizontalpodautoscaler.autoscaling/scale-docker-app autoscaled
```

as you can see, on a tipically not very loaded cluster, applying autoscaling
doesn't change anything:

```
> oc get rs
NAME                          DESIRED   CURRENT   READY   AGE
scale-docker-app-5b7ccb8dd5   1         1         1       11m
```

but a new HorizontalPodAutoscaling resource was created:

```
> oc get hpa
NAME               REFERENCE                     TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
scale-docker-app   Deployment/scale-docker-app   <unknown>/50%   1         3         1          2m17s
```

here you can find the autoscaling specs:

```
> oc describe hpa scale-docker-app
...
Metrics:                                               ( current / target )
  resource cpu on pods  (as a percentage of request):  <unknown> / 50%
Min replicas:                                          1
Max replicas:                                          3
...
```
