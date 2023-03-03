# Exercise | Kubernetes Attach PVC To Deployment | Solution

1. Use `kubectl run` to run the nginx deployment:

   ```console
   > kubectl -n volumes-test create deployment nginx --image=nginx:latest
   deployment.apps/nginx created

   > kubectl -n volumes-test get pod
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-6d666844f6-8t28s   1/1     Running   0          10s
   ```

2. Edit the deployment definition adding the `volumes` and `volumeMounts`
   sections inside the `spec`:

   ```console
   kubectl -n volumes-test edit deployment nginx
   ```

   ```yaml
   apiVersion: apps/v1                                                             
   kind: Deployment                                                                
   ...
   spec: 
   ...
       spec:                                                                       
         containers:                                                               
         - image: nginx:latest                                                     
           imagePullPolicy: Always                                                 
           name: nginx                                                             
           resources: {}                                                           
           terminationMessagePath: /dev/termination-log                            
           terminationMessagePolicy: File                                          
           volumeMounts:                                                           
           - mountPath: /usr/share/nginx/html                                      
             name: nginx-docroot                                                   
         volumes:                                                                  
         - name: nginx-docroot                                                     
           persistentVolumeClaim:                                                  
             claimName: myclaim
   ...
   ```

   ```console
   deployment.apps/nginx edited
   ```

   Then check the status of the objects:

   ```yaml
   > kubectl -n volumes-test get all
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-84655c5fd7-fk7sc   1/1     Running   0          19s
   
   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   1/1     1            1           53s
   
   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   0         0         0       53s
   replicaset.apps/nginx-84655c5fd7   1         1         1       19s
   ```

   The replicaset create a new pod to mount the volume.

3. Create the file using `minikube ssh`:

   ```console
   > minikube ssh

   docker@minikube:~$ sudo bash -c "echo 'THIS COMES FROM MY VOLUME' > /data/index.html"
   ```

4. Using port-forward expose locally the 80 port and check with `curl` if nginx
   is using the volume:

   ```console
   > kubectl -n volumes-test get pods
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-84655c5fd7-xgm2f   1/1     Running   0          8m34s

   > kubectl -n volumes-test port-forward nginx-84655c5fd7-xgm2f 8080:80
   Forwarding from 127.0.0.1:8080 -> 80
   Forwarding from [::1]:8080 -> 80
   ```

   And from another console:

   ```console
   >  curl localhost:8080
   THIS COMES FROM MY VOLUME
   ```

5. Delete the namespace and see the new PV status:

   ```console
   > kubectl get pv pv0001 
   NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
   pv0001   5Gi        RWO            Retain           Bound    volumes-test/myclaim   localpv                 30m

   >  kubectl delete namespace volumes-test 
   namespace "volumes-test" deleted

   >  kubectl get pv pv0001 
   NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                  STORAGECLASS   REASON   AGE
   pv0001   5Gi        RWO            Retain           Released   volumes-test/myclaim   localpv                 30m
   ```

   Status is `Released` because `myclaim` was deleted with the namespace.
