# Exercise 013 - Create a PVC and see details of bounded PV - Solutions

---

1. Login as developer on the cluster:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ```

   Write a yaml with the PersistentVolumeClaim definition:

   ```console
   > cat myclaim.yml
   ---
   kind: PersistentVolumeClaim
   apiVersion: v1
   metadata:
     name: myclaim
     spec:
       accessModes:
         - ReadWriteOnce
       resources:
         requests:
           storage: 2Gi
   ```

   Create the claim on the cluster:

   ```console
   > oc create -f myclaim.yml
   persistentvolumeclaim/myclaim created
   ```

2. Check the state of the PersistentVolumeClaim:

   ```console
   > oc get pvc
   NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   myclaim   Bound    pv0016   100Gi      RWO,ROX,RWX                   51s
   ```

   Seems the claim bounds to the PersistentVolume pv0016. Show details of the
   claim:

   ```console
   > oc describe pvc myclaim
   Name:          myclaim
   Namespace:     route-test
   StorageClass:
   Status:        Bound
   Volume:        pv0016
   Labels:        <none>
   Annotations:   pv.kubernetes.io/bind-completed: yes
                  pv.kubernetes.io/bound-by-controller: yes
                           Finalizers:    [kubernetes.io/pvc-protection]
                           Capacity:      100Gi
                           Access Modes:  RWO,ROX,RWX
                           VolumeMode:    Filesystem
                           Used By:       <none>
                           Events:        <none>
   ```

3. Check the available PersitentVolumes on the cluster:

   ```console
   > oc get pv
   Error from server (Forbidden): persistentvolumes is forbidden: User "developer" cannot list resource "persistentvolumes" in API group "" at the cluster scope
   ```

   PersistentVolume resources are managed only by admins, and are usually not
   available for developers. Login as the kubeadmin user:

   ```
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ```

   Then obtain the list of the available PersistentVolumes:

   ```console
   > oc get pv
   NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                                 STORAGECLASS   REASON   AGE
   pv0001   100Gi      RWO,ROX,RWX    Recycle          Bound       openshift-image-registry/crc-image-registry-storage                           13d
   pv0002   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 13d
   pv0003   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 13d
   pv0004   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 13d
   pv0005   100Gi      RWO,ROX,RWX    Recycle          Available                                                                                 13d
   ...
   ```

   Then show the details of the pv0016:

   ```console
   > oc describe pv pv0016
   Name:            pv0016
   Labels:          volume=pv0016
   Annotations:     <none>
   Finalizers:      [kubernetes.io/pv-protection]
   StorageClass:
   Status:          Available
   Claim:
   Reclaim Policy:  Recycle
   Access Modes:    RWO,ROX,RWX
   VolumeMode:      Filesystem
   Capacity:        100Gi
   Node Affinity:   <none>
   Message:
   Source:
       Type:          HostPath (bare host directory volume)
       Path:          /mnt/pv-data/pv0016
       HostPathType:
       Events:
       Type    Reason          Age   From                         Message
       ----    ------          ----  ----                         -------
       Normal  RecyclerPod     3m4s  persistentvolume-controller  Recycler pod: Successfully assigned openshift-infra/recycler-for-pv0016 to crc-4727w-master-0
       Normal  RecyclerPod     3m2s  persistentvolume-controller  Recycler pod: Add eth0 [10.217.0.183/23]
       Normal  RecyclerPod     3m1s  persistentvolume-controller  Recycler pod: Container image "quay.io/openshift-release-dev/ocp-v4.0-art-dev@sha256:ffadee3c5e06edab18f0661d768314bcdd88c5c0d65814097bc3e95b00e2c714" already present on machine
       Normal  RecyclerPod     3m1s  persistentvolume-controller  Recycler pod: Created container recycler-container
       Normal  RecyclerPod     3m    persistentvolume-controller  Recycler pod: Started container recycler-container
       Normal  VolumeRecycled  3m    persistentvolume-controller  Volume recycled
   ```
