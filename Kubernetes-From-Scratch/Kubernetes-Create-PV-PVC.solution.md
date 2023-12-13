# Lab | Kubernetes Create PV PVC

In this lab you will:

1. Create a PV of 5G pointing to the `/data` directory and a `storageClassName` named `localpv`.
2. Create a namespace named `volumes-test` with a PersistentVolumeClaim of 1G claiming for the `storageClassName` named `localpv`.
3. Find the bounded volumes and show the details;

## Solution

1. Create a yaml file with the Persistent Volume named 'pv001' definition:

   ```console
   > cat pv-test.yml
   ```
   
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
   > kubectl create -f pv-test.yml
   persistentvolume/pv0001 created

   > kubectl get pv
   NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
   pv0001   5Gi        RWO            Retain           Available           localpv                 108s
   ```

2. Create the namespace:

   ```console
   >  kubectl create namespace volumes-test
   namespace/volumes-test created
   ```

   Then create a yaml file named `pvc-test.yml` with a claim of 1G:

   ```console
   > cat pvc-test.yml
   ```

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
   >  kubectl create -f pvc-test.yml
   persistentvolumeclaim/myclaim created

   > kubectl -n volumes-test get pvc
   NAMESPACE      NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   volumes-test   myclaim   Bound    pv0001   5Gi        RWO            localpv        7s
   ```

3. The status can be seen with `kubectl describe`:

   ```console
   >  kubectl describe pv pv0001
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

   > kubectl -n volumes-test describe pvc myclaim 
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
