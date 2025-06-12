# Lab | Kubernetes Scale And Autoscale

In this lab you will:

1. Create a namespace named `scale-test`.
2. Deploy an `nginx` deployment inside the `scale-test` namespace.
3. Check the ReplicaSet and see if requirements are met;
4. Scale the application up to 3 replicas. Check changes in the ReplicaSet and
   in the running pods.
5. Scale down the application to 1 replica. Check and see when the operation
   ends.
6. Configure autoscaling on this application with a minumum of 1 pod, a maximum
   of 3 pods based on a CPU load of 50%. Then check if everything changed as
   expected.
7. Install the `stress` command inside the `nginx` pod and launch it with
   `stress --cpu 3` to increase the CPU load. Then check if pod replicas are
   increased by hpa.
8. Stop `stress` command and check that the replicas come back to 1.

## Solution

1. Create the new namespace:

   ```console
   $ kubectl create namespace scale-test
   namespace/scale-test created
   ```

2. Create the `nginx` deployment:

   ```console
   $ kubectl --namespace scale-test create deployment nginx --image=nginx:latest
   deployment.apps/nginx created

   $ kubectl --namespace scale-test get all
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-wwdzc   1/1     Running   0          29s

   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   1/1     1            1           29s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       29s
   ```

3. Get a list of ReplicaSet:

   ```console
   $ kubectl --namespace scale-test get replicasets.apps
   NAME               DESIRED   CURRENT   READY   AGE
   nginx-6d666844f6   1         1         1       55
   ```

   Then see the ReplicaSet specification:

   ```console
   $ kubectl --namespace scale-test describe replicasets.apps nginx-6d666844f6
   Name:           nginx-6d666844f6
   Namespace:      scale-test
   ...
   Replicas:       1 current / 1 desired
   Pods Status:    1 Running / 0 Waiting / 0 Succeeded / 0 Failed
   ...
   ```

   Requirements are met.

4. Change the replicas with `kubectl scale`:

   ```console
   $ kubectl --namespace scale-test scale --replicas=3 deployment nginx
   deployment.apps/nginx scaled
   ```

   If you quickly check again the ReplicaSet you can see the current status:

   ```console
   ...
   Replicas:       3 current / 3 desired
   Pods Status:    1 Running / 2 Waiting / 0 Succeeded / 0 Failed
   ...
   ```

   After few moments everything is scaled:

   ```console
   ...
   Replicas:       3 current / 3 desired
   Pods Status:    3 Running / 0 Waiting / 0 Succeeded / 0 Failed
   ...
   ```

   There are more pods now:

   ```console
   $ kubectl --namespace scale-test get pods
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-6d666844f6-dv8xl   1/1     Running   0          77s
   nginx-6d666844f6-j2n7w   1/1     Running   0          77s
   nginx-6d666844f6-wwdzc   1/1     Running   0          4m30s
   ```

5. Use `kubectl scale` again to reduce the number of replicas:

   ```console
   $ kubectl --namespace scale-test scale --replicas=1 deployment nginx
   deployment.apps/nginx scaled
   ```

   Quickly, the replicas scale down to 1:

   ```console
   $ kubectl --namespace scale-test get pods,rs
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-wwdzc   1/1     Running   0          5m56s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       5m56s
   ```

6. It is possible to configure autoscale with a single `kubectl autoscale`
   command:

   ```console
   $ kubectl --namespace scale-test autoscale deployment nginx \
       --min 1 --max 3 --cpu-percent=50
   horizontalpodautoscaler.autoscaling/nginnx autoscaled
   ```

   As you can see, on a tipically not very loaded cluster, applying autoscaling
   doesn't change anything:

   ```console
   $ kubectl --namespace scale-test get pods,rs
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-wwdzc   1/1     Running   0          8m1s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       8m1s
   ```

   But a new HorizontalPodAutoscaling resource was created:

   ```console
   $ kubectl --namespace scale-test get hpa
   NAME    REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
   nginx   Deployment/nginx   <unknown>/50%   1         3         1          92s
   ```

   Here you can find the autoscaling specs:

   ```console
   $ kubectl --namespace scale-test describe hpa nginx
   ...
   Metrics:                                               ( current / target )
     resource cpu on pods  (as a percentage of request):  <unknown> / 50%
   Min replicas:                                          1
   Max replicas:                                          3
   ...
   ```

   To make everything *effectively* work, the metrics server must be enabled in
   minikube, with:

   ```console
   $ minikube addons enable metrics-server
   💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
   You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
       ▪ Using image k8s.gcr.io/metrics-server/metrics-server:v0.6.1
   🌟  The 'metrics-server' addon is enable
   ```

   Due to [this limitation](https://github.com/kubernetes-sigs/metrics-server/issues/989#issuecomment-1313971365)
   to make the `<unknown>` value disappear a `request` must be added to the
   deployment:

   ```console
   $ kubectl --namespace scale-test set resources deployment nginx --requests=cpu=200m
   deployment.apps/nginx resource requirements updated

   $ kubectl --namespace scale-test get hpa
   NAME    REFERENCE          TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
   nginx   Deployment/nginx   0%/50%    1         3         1          3h39m
   ```

   The `<unknown>` value is finally gone.

7. Install `stress` in the `nginx` pod:

   ```console
   $ kubectl --namespace scale-test exec \
       --stdin --tty \
       nginx-69d7f674df-lvrzw -- /bin/bash
   root@nginx-69d7f674df-lvrzw:/# apt-get update
   ...
   Reading package lists... Done

   root@nginx-69d7f674df-lvrzw:/# apt-get -y install stress
   ...
   Setting up stress (1.0.4-7) ...
   ```

   Then launch `stress` to start consuming cpu:

   ```console
   root@nginx-69d7f674df-lvrzw:/# stress --cpu 3
   stress: info: [312] dispatching hogs: 3 cpu, 0 io, 0 vm, 0 hdd
   ```

   From another console check the status of the deployment:

   ```console
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-69d7f674df-ghq44   1/1     Running   0          26s
   pod/nginx-69d7f674df-klkn9   1/1     Running   0          26s
   pod/nginx-69d7f674df-lvrzw   1/1     Running   0          49m

   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   3/3     3            3           3h21m

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-67b86fd54d   0         0         0       50m
   replicaset.apps/nginx-69d7f674df   3         3         3       49m
   replicaset.apps/nginx-6d666844f6   0         0         0       3h21m

   NAME                                        REFERENCE          TARGETS      MINPODS   MAXPODS   REPLICAS   AGE
   horizontalpodautoscaler.autoscaling/nginx   Deployment/nginx   24500%/50%   1         3         3          3h16m
   ```

   The `TARGETS` column is saying that we're consuming *a lot* of cpu :).

8. You can stop with Ctrl+C the `stress` command and check the targets:

   ```console
   $ kubectl --namespace scale-test get hpa
   NAME                                        REFERENCE          TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
   horizontalpodautoscaler.autoscaling/nginx   Deployment/nginx   0%/50%    1         3         3          3h19m
   ```

   After some time (at least 10 minutes), hpa should reduce the amount of pods:

   ```console
   $ kubectl --namespace scale-test describe hpa
   ...
     Type    Reason             Age   From                       Message
     ----    ------             ----  ----                       -------
     Normal  SuccessfulRescale  10m   horizontal-pod-autoscaler  New size: 3; reason: cpu resource utilization (percentage of request) above target
     Normal  SuccessfulRescale  4m6s  horizontal-pod-autoscaler  New size: 2; reason: All metrics below target
     Normal  SuccessfulRescale  6s    horizontal-pod-autoscaler  New size: 1; reason: All metrics below target

   $ kubectl --namespace scale-test get pods
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-69d7f674df-lvrzw   1/1     Running   0          60m
   ```
