# Exercise 015 - Scale-up, scale-down and configure autoscaling - Solutions

---

1. Create the new namespace:

   ```console
   > kubectl create namespace scale-test
   namespace/scale-test created
   ```

2. Create the `nginx` deployment:

   ```console
   >  kubectl -n scale-test create deployment nginx --image=nginx:latest
   deployment.apps/nginx created

   > kubectl -n scale-test get all
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-wwdzc   1/1     Running   0          29s
   
   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   1/1     1            1           29s
   
   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       29s
   ```

3. Get a list of ReplicaSet:

   ```console
   > kubectl -n scale-test get replicasets.apps
   NAME               DESIRED   CURRENT   READY   AGE
   nginx-6d666844f6   1         1         1       55
   ```

   Then see the ReplicaSet specification:

   ```console
   > kubectl -n scale-test describe replicasets.apps nginx-6d666844f6 
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
   > kubectl -n scale-test scale --replicas=3 deployment nginx
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
   > kubectl -n scale-test get pods
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-6d666844f6-dv8xl   1/1     Running   0          77s
   nginx-6d666844f6-j2n7w   1/1     Running   0          77s
   nginx-6d666844f6-wwdzc   1/1     Running   0          4m30s
   ```

5. Use `kubectl scale` again to reduce the number of replicas:

   ```console
   > kubectl -n scale-test scale --replicas=1 deployment nginx
   deployment.apps/nginx scaled
   ```

   Quickly, the replicas scale down to 1:
   
   ```console
   > kubectl -n scale-test get pods,rs
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-wwdzc   1/1     Running   0          5m56s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       5m56s
   ```

6. It is possible to configure autoscale with a single `kubectl autoscale` command:

   ```console
   > kubectl -n scale-test autoscale deployment nginx --min 1 --max 3 --cpu-percent=50
   horizontalpodautoscaler.autoscaling/nginnx autoscaled
   ```

   As you can see, on a tipically not very loaded cluster, applying autoscaling doesn't change anything:

   ```console
   > kubectl -n scale-test get pods,rs
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-wwdzc   1/1     Running   0          8m1s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       8m1s
   ```
   
   But a new HorizontalPodAutoscaling resource was created:
   
   ```console
   > kubectl -n scale-test get hpa
   NAME    REFERENCE          TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
   nginx   Deployment/nginx   <unknown>/50%   1         3         1          92s
   ```

   Here you can find the autoscaling specs:

   ```console
   > kubectl -n scale-test describe hpa nginx
   ...
   Metrics:                                               ( current / target )
     resource cpu on pods  (as a percentage of request):  <unknown> / 50%
   Min replicas:                                          1
   Max replicas:                                          3
   ...
   ```

   To make everything *effectively* work, and so make the `<unknown>` disappear from the outputs, the metrics server must be enabled in minikube, with:

   ```console
   > minikube addons enable metrics-server
   💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
   You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
       ▪ Using image k8s.gcr.io/metrics-server/metrics-server:v0.6.1
   🌟  The 'metrics-server' addon is enable
   ```

   And after some time the `<unknown>` should disappear.
