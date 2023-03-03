# Exercise | Kubernetes First Deployment | Solution

1. Create a new namespace with `kubectl create namespace`:

   ```console
   > kubectl create namespace my-first-project
   namespace/my-first-project created
   ```

2. Use `kubectl create deployment` to create a new deployment:

   ```console
   > kubectl -n my-first-project create deployment nginx --image=nginx:latest
   deployment.apps/nginx created
   ```

3. Check the status via `kubectl get all`:

   ```console
   > kubectl -n my-first-project get all
   NAME                         READY   STATUS              RESTARTS   AGE
   pod/nginx-6d666844f6-htkms   0/1     ContainerCreating   0          3s

   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   0/1     1            0           3s
   
   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         0       3s
   ```

   After some time you should see everything running:

   ```console
   > kubectl -n my-first-project get all
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-k9d5l   1/1     Running   0          15s
   
   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   1/1     1            1           15s
   
   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       15s
   ```

4. First identify the name of the pod:

   ```console
   > kubectl -n my-first-project get pods
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-6d666844f6-k9d5l   1/1     Running   0          66s
   ```

   Then use ```kubectl port-forward``` to reach the 80 port of the container and map it to the localhost 8080:

   ```console
   > kubectl -n my-first-project port-forward deployment/nginx 8080:80
   Forwarding from 127.0.0.1:8080 -> 80
   Forwarding from [::1]:8080 -> 80
   ```

5. From another console, use `curl` to reach the exposed port:

   ```console
   > curl localhost:8080
   <!DOCTYPE html>
   <html>
   <head>
   <title>Welcome to nginx!</title>
   <style>
   html { color-scheme: light dark; }
   body { width: 35em; margin: 0 auto;
   font-family: Tahoma, Verdana, Arial, sans-serif; }
   </style>
   </head>
   <body>
   <h1>Welcome to nginx!</h1>
   <p>If you see this page, the nginx web server is successfully installed and
   working. Further configuration is required.</p>
   
   <p>For online documentation and support please refer to
   <a href="http://nginx.org/">nginx.org</a>.<br/>
   Commercial support is available at
   <a href="http://nginx.com/">nginx.com</a>.</p>
   
   <p><em>Thank you for using nginx.</em></p>
   </body>
   </html>
   ```

6. Use `kubectl delete` to remove the project:

   ```console
   > kubectl delete namespace my-first-project
   namespace "my-first-project" deleted
   ```
