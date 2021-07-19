# Exercise 014 - Attach a PVC object to a DC, then create a new one updating a DC

---

1. First, login as 'developer' on your cluster:

   ```console
   > oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ```

   Then create a new project:

   ```console
   > oc new-project teststorage
   Now using project "teststorage" on server "https://api.crc.testing:6443".
   ```

2. You can use an easy "oc create" command to create the DeploymentConfig:

   ```console
   > oc create deploymentconfig tomcat --image=tomcat
   deploymentconfig.apps.openshift.io/tomcat created
   ```

   Then wait everything goes up&running:

   ```console
   > oc get deploymentconfig
   NAME     REVISION   DESIRED   CURRENT   TRIGGERED BY
   tomcat   1          1         1         config

   > oc get pods
   NAME              READY   STATUS      RESTARTS   AGE
   tomcat-1-deploy   0/1     Completed   0          48s
   tomcat-1-k5tgk    1/1     Running     0          44s

   > oc logs tomcat-1-k5tgk
   ...
   16-Jul-2021 08:25:29.416 INFO [main] org.apache.coyote.AbstractProtocol.start Starting ProtocolHandler ["http-nio-8080"]
   16-Jul-2021 08:25:29.480 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in [213] milliseconds
   ```

3. Check all available claims:

   ```console
   > oc get pvc
   No resources found in teststorage namespace.
   ```

   So, create a new yaml file defining the claim:

   ```console
   > cat tomcat-claim.yaml
   ---
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: tomcat-claim
   spec:
     accessModes:
       - ReadWriteOnce
     resources:
       requests:
         storage: 2Gi
   ```

   and add the claim to the cluster

   ```console
   > oc create -f tomcat-claim.yaml
   persistentvolumeclaim/tomcat-claim created
   ```

4. Show the available claims on the cluster:

   ```console
   > oc get pvc
   NAME           STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   tomcat-claim   Bound    pv0025   100Gi      RWO,ROX,RWX                   42s
   ```

   You can now edit the DeploymentConfig adding the volume in the pod
   specification, and the claim as the available volumes:

   ```console
   > oc edit deploymentconfig tomcat
   ...
       spec:
         containers:
         - image: tomcat
           imagePullPolicy: Always
   ...
           volumeMounts:
             - mountPath: /claim
               name: tomcat-claim
         volumes:
           - name: tomcat-claim
             persistentVolumeClaim:
               claimName: tomcat-claim
   ...
   deploymentconfig.apps.openshift.io/tomcat edited
   ```

5. Describing the tomcat DeploymentConfig you will get informations about the
   claim and the mountpoint:

   ```console
   > oc describe deploymentconfig tomcat
   ...
     Containers:
      default-container:
       Image:              tomcat
       Port:               <none>
       Host Port:          <none>
       Environment:        <none>
       Mounts:
         /claim from tomcat-claim (rw)
     Volumes:
      tomcat-claim:
       Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
       ClaimName:  tomcat-claim
       ReadOnly:   false
   ...
   ```

   Obtain the tomcat pod name:

   ```console
   > oc get pods -l deployment-config.name=tomcat
   NAME             READY   STATUS    RESTARTS   AGE
   tomcat-2-vtt48   1/1     Running   0          2m26s
   ```

   Check if you can ls the path:

   ```console
   > oc exec tomcat-2-vtt48 -- ls -al /claim
   total 0
   drwxrwx---. 2 root root  6 Jul  2 04:01 .
   dr-xr-xr-x. 1 root root 63 Jul 16 08:46 ..
   ```

   Then see the mount specifications:

   ```console
   > oc exec tomcat-2-vtt48 -- mount | grep claim
   /dev/vda4 on /claim type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,prjquota)
   ```

6. Defining and attaching a claim to a DeploymentConfig is possibile with a single
   oc command.

   ```console
   > oc set volume deploymentconfig tomcat --add --name=tomcat-storage \
       -m /storage -t pvc --claim-name=tomcat-storage \
       --claim-size=2Gi --claim-mode="ReadWriteOnce"
   deploymentconfig.apps.openshift.io/tomcat volume updated
   ```

7. You can check the DeploymentConfig definition to see the new claim and mount:

   ```console
   > oc describe deploymentconfig tomcat
   ...
       Mounts:
         /claim from tomcat-claim (rw)
         /storage from tomcat-storage (rw)
   ...
     Volumes:
      tomcat-claim:
       Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
       ClaimName:  tomcat-claim
       ReadOnly:   false
      tomcat-storage:
       Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
       ClaimName:  tomcat-storage
       ReadOnly:   false
   ...
   ```

   And see the lclaim in the cluster:

   ```console
   > oc get pvc
   NAME             STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   tomcat-claim     Bound    pv0025   100Gi      RWO,ROX,RWX                   18m
   tomcat-storage   Bound    pv0019   100Gi      RWO,ROX,RWX                   3m18s
   ```

   Also the pod will have it mounted and available:

   ```console
   > oc get pods -l deployment-config.name=tomcat
   NAME             READY   STATUS    RESTARTS   AGE
   tomcat-3-pcspb   1/1     Running   0          3m56s

   > oc exec tomcat-3-pcspb -- mount | grep \/storage\
   /dev/vda4 on /storage type xfs (rw,relatime,seclabel,attr2,inode64,logbufs=8,logbsize=32k,prjquota)

   > oc exec tomcat-3-pcspb -- ls -al /storage
   total 0
   drwxrwx---. 2 root root  6 Jul  2 04:01 .
   dr-xr-xr-x. 1 root root 78 Jul 16 08:52 ..
   ```
