# Lab | Kubernetes Attach PVC To Deployment

In this lab you will:

1. Create a PV of 5G pointing to the `/data` directory and a `storageClassName`
   named `localpv`.
2. Create a namespace named `volumes-test` with a PersistentVolumeClaim of 1G
   claiming for the `storageClassName` named `localpv`.
3. Find the bounded volumes and show the details.
4. Run inside the `volumes-test` namespace an `nginx` pod.
5. Mount the PVC named `myclaim` in the `/usr/share/nginx/html` directory.
6. From the minikube host create an `index.html` file inside
   `/usr/share/nginx/html` displaying `THIS COMES FROM MY VOLUME`.
7. Check if the message is correctly displayed.
8. Delete the `volumes-test` namespace and check the status of the persistent
   volume.

## Solution

1. Create a `pv-test.yml` yaml file with the Persistent Volume named 'pv001'
   definition:

   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: pv0001
   spec:
     storageClassName: localpv
     accessModes:
       - ReadWriteOnce
     capacity:
       storage: 5Gi
     hostPath:
       path: /data/
   ```

   Create the resource by using `kubectl create -f pv001.yaml` command:

   ```console
   $ kubectl create -f pv-test.yml
   persistentvolume/pv0001 created

   $ kubectl get pv
   NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
   pv0001   5Gi        RWO            Retain           Available           localpv                 108s
   ```

2. Create the namespace:

   ```console
   $  kubectl create namespace volumes-test
   namespace/volumes-test created
   ```

   Then create a yaml file named `pvc-test.yml` with a claim of 1G:

   ```yaml
   kind: PersistentVolumeClaim
   apiVersion: v1
   metadata:
     name: myclaim
     namespace: volumes-test
   spec:
     storageClassName: localpv
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 1Gi
   ```

   Create and check the claim:

   ```console
   $  kubectl create -f pvc-test.yml
   persistentvolumeclaim/myclaim created

   $ kubectl -n volumes-test get pvc
   NAMESPACE      NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   volumes-test   myclaim   Bound    pv0001   5Gi        RWO            localpv        7s
   ```

3. The status can be seen with `kubectl describe`:

   ```console
   $  kubectl describe pv pv0001
   Name:            pv0001
   Labels:          <none>
   Annotations:     <none>
   Finalizers:      [kubernetes.io/pv-protection]
   StorageClass:    localpv
   Status:          Available
   Claim:
   Reclaim Policy:  Retain
   Access Modes:    RWO
   VolumeMode:      Filesystem
   Capacity:        5Gi
   Node Affinity:   <none>
   Message:
   Source:
       Type:          HostPath (bare host directory volume)
       Path:          /data/
       HostPathType:
   Events:            <none>

   $ kubectl -n volumes-test describe pvc myclaim
   Name:          myclaim
   Namespace:     volumes-test
   StorageClass:  localpv
   Status:        Bound
   Volume:        pv0001
   Labels:        <none>
   Annotations:   pv.kubernetes.io/bind-completed: yes
                  pv.kubernetes.io/bound-by-controller: yes
   Finalizers:    [kubernetes.io/pvc-protection]
   Capacity:      5Gi
   Access Modes:  RWO
   VolumeMode:    Filesystem
   Used By:       <none>
   Events:        <none>
   ```

   Note that PVC lives at namespace level, and PV at cluster level.
4. Use `kubectl run` to run the nginx deployment:

   ```console
   $ kubectl -n volumes-test create deployment nginx --image=nginx:latest
   deployment.apps/nginx created

   $ kubectl -n volumes-test get pod
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-6d666844f6-8t28s   1/1     Running   0          10s
   ```

5. Edit the deployment definition adding the `volumes` and `volumeMounts`
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
   $ kubectl -n volumes-test get all
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-84655c5fd7-fk7sc   1/1     Running   0          19s

   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   1/1     1            1           53s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   0         0         0       53s
   replicaset.apps/nginx-84655c5fd7   1         1         1       19s
   ```

   The replicaset create a new pod to mount the volume.

6. Create the file using `minikube ssh`:

   ```console
   $ minikube ssh

   docker@minikube:~$ sudo bash -c "echo 'THIS COMES FROM MY VOLUME' > /data/index.html"
   ```

7. Using port-forward expose locally the 80 port and check with `curl` if nginx
   is using the volume:

   ```console
   $ kubectl -n volumes-test get pods
   NAME                     READY   STATUS    RESTARTS   AGE
   nginx-84655c5fd7-xgm2f   1/1     Running   0          8m34s

   $ kubectl -n volumes-test port-forward nginx-84655c5fd7-xgm2f 8080:80
   Forwarding from 127.0.0.1:8080 -> 80
   Forwarding from [::1]:8080 -> 80
   ```

   And from another console:

   ```console
   $  curl localhost:8080
   THIS COMES FROM MY VOLUME
   ```

8. Delete the namespace and see the new PV status:

   ```console
   $ kubectl get pv pv0001
   NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
   pv0001   5Gi        RWO            Retain           Bound    volumes-test/myclaim   localpv                 30m

   $  kubectl delete namespace volumes-test
   namespace "volumes-test" deleted

   $  kubectl get pv pv0001
   NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                  STORAGECLASS   REASON   AGE
   pv0001   5Gi        RWO            Retain           Released   volumes-test/myclaim   localpv                 30m
   ```

   Status is `Released` because `myclaim` was deleted with the namespace.
