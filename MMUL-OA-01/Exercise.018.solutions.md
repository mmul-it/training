# Exercise 018 - Scale-up, scale-down and configure autoscaling - Solutions

---

1. Login as the developer user:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ```

   then create a new project:

   ```console
   > oc new-project testscale
   Now using project "testscale" on server "https://api.crc.testing:6443".
   ```

2. You can do that by using the "oc new-app" command:

   ```console
   > oc new-app --name=scale-docker-app https://github.com/mmul-it/docker --context-dir=s2i-php-helloworld
   --> Found image b416a19 (3 weeks old) in image stream "openshift/php" under tag "7.4-ubi8" for "php"
   ...
   ```

   Then follow the build with:

   ```console
   > oc logs -f buildconfig/scale-docker-app
   ...
   Successfully pushed image-registry.openshift-image-registry.svc:5000/testscale/scale-docker-app@sha256:dce19687cf5d926b1178e6ed3ddd8d312a13c995d5590761ed77dd7e13ea871b
   Push successful
   ```
   You can see there is a pod running the app now:

   ```console
   > oc get pods
   NAME                                READY   STATUS      RESTARTS   AGE
   scale-docker-app-1-build            0/1     Completed   0          2m38s
   scale-docker-app-5b7ccb8dd5-qdz5c   1/1     Running     0          17s
   ```

3. Obtaining a list of Replication Controller:

   ```console
   > oc get rc
   NAME                          DESIRED   CURRENT   READY   AGE
   scale-docker-app-5b7ccb8dd5   1         1         1       72s
   ```

   Then see the Replication Controller specification:

   ```console
   > oc describe rc scale-docker-app-5b7ccb8dd5
   ...
   Replicas:       1 current / 1 desired
   Pods Status:    1 Running / 0 Waiting / 0 Succeeded / 0 Failed
   ...
   ```
   Requisites are met.

4. Change the replicas with ```oc scale```:

   ```console
   > oc scale --replicas=3 deployment scale-docker-app
   deployment.apps/scale-docker-app scaled
   ```
   
   If you quickly check again the Replication Controller you can see the
   current status:
   
   ```console
   > oc describe rc scale-docker-app-5b7ccb8dd5
   ...
   Replicas:       3 current / 3 desired
   Pods Status:    1 Running / 2 Waiting / 0 Succeeded / 0 Failed
   ...
   ```

   After few moments everything is scaled:

   ```console
   > oc describe rc scale-docker-app-5b7ccb8dd5
   ...
   Replicas:       3 current / 3 desired
   Pods Status:    3 Running / 0 Waiting / 0 Succeeded / 0 Failed
   ...
   ```
   There are more pods now:
   
   ```console
   oc get pods
   NAME                                READY   STATUS      RESTARTS   AGE
   scale-docker-app-1-build            0/1     Completed   0          8m45s
   scale-docker-app-5b7ccb8dd5-gn6kn   1/1     Running     0          3m8s
   scale-docker-app-5b7ccb8dd5-khzkh   1/1     Running     0          3m8s
   scale-docker-app-5b7ccb8dd5-qdz5c   1/1     Running     0          6m24s
   ```

5. Use ```oc scale``` again to reduce the number of replicas:

   ```console
   > oc scale --replicas=1 deployment scale-docker-app
   deployment.apps/scale-docker-app scaled
   ```

   Quickly, the replicas scale down to 1:
   
   ```console
   > oc get rc
   NAME                          DESIRED   CURRENT   READY   AGE
   scale-docker-app-5b7ccb8dd5   1         1         1       8m11s

   > oc get pods
   NAME                                READY   STATUS      RESTARTS   AGE
   scale-docker-app-1-build            0/1     Completed   0          10m
   scale-docker-app-5b7ccb8dd5-qdz5c   1/1     Running     0          8m25s
   ```

6. Autoscaling can also be done with a single command:

   ```console
   > oc autoscale deployment scale-docker-app --min 1 --max 3 --cpu-percent=50
   horizontalpodautoscaler.autoscaling/scale-docker-app autoscaled
   ```

   As you can see, on a tipically not very loaded cluster, applying autoscaling
   doesn't change anything:

   ```console
   > oc get rc
   NAME                          DESIRED   CURRENT   READY   AGE
   scale-docker-app-5b7ccb8dd5   1         1         1       11m
   ```
   
   But a new HorizontalPodAutoscaling resource was created:
   
   ```console
   > oc get hpa
   NAME               REFERENCE                     TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
   scale-docker-app   Deployment/scale-docker-app   <unknown>/50%   1         3         1          2m17s
   ```

   Here you can find the autoscaling specs:

   ```console
   > oc describe hpa scale-docker-app
   ...
   Metrics:                                               ( current / target )
     resource cpu on pods  (as a percentage of request):  <unknown> / 50%
   Min replicas:                                          1
   Max replicas:                                          3
   ...
   ```

   Cleanup everything:

   ```console
   > oc delete project  testscale
   project.project.openshift.io "testscale" deleted
   ```

   **Important note!**: due to https://github.com/code-ready/crc/issues/921 the
   scale cannot be simulated into crc.
   Result will be something like this:

   ```console
   > oc describe hpa scale-docker-app
   ...
   ...
   Events:
     Type     Reason                        Age   From                       Message
     ----     ------                        ----  ----                       -------
     Warning  FailedGetResourceMetric       5s    horizontal-pod-autoscaler  failed to get cpu utilization: missing request for cpu
     Warning  FailedComputeMetricsReplicas  5s    horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu utilization: missing request for cpu
   ```

   The error could be related to the absence of the cluster monitoring
   component, that can be enabled with these steps:

   ```console
   > crc stop
   INFO Deleting the pods from openshift-machine-config-operator namespace 
   INFO Stopping the OpenShift cluster, this may take a few minutes... 
   Stopped the OpenShift cluster

   > crc config set memory 14336   
   Changes to configuration property 'memory' are only applied when the CRC instance is started.
   If you already have a running CRC instance, then for this configuration change to take effect, stop the CRC instance with 'crc stop' and restart it with 'crc start'.

   > crc config set enable-cluster-monitoring true
   Successfully configured enable-cluster-monitoring to true

   > crc start
   ...
   ```

   But at the moment even with these settings crc is still missing this.
