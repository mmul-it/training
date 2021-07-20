# Exercise 012 - Find HAProxy stats page details - Solutions

1. Login as 'kubeadmin':

   ```console
   > oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ```

   Switch to the openshift-ingress namespace:

   ```console
   > oc project openshift-ingress
   Now using project "openshift-ingress" on server "https://api.crc.testing:6443".
   ```

   List pods in the project:

   ```console
   > oc get pods
   NAME                             READY   STATUS    RESTARTS   AGE
   router-default-5f7c456ff-pxgf7   1/1     Running   2          13d
   routes-controller                1/1     Running   0          5h12m
   ```

   The router pod is router-default-5f7c456ff-pxgf7.

2. Filter by STATS environment variables in the pod specifications:

   ```console
   > oc describe pod router-default-5f7c456ff-pxgf7 | grep STATS
   STATS_PASSWORD:                            <set to the key 'statsPassword' in secret 'router-stats-default'>  Optional: false
   STATS_PORT:                                1936
   STATS_USERNAME:                            <set to the key 'statsUsername' in secret 'router-stats-default'>  Optional: false
   ```

3. Check if the router-stats-default secret contains the two keys reported in the
previous output:

   ```console
   > oc describe secret router-stats-default
   Name:         router-stats-default
   Namespace:    openshift-ingress
   Labels:       <none>
   Annotations:  <none>

   Type:  Opaque

   Data
   ====
   statsPassword:  12 bytes
   statsUsername:  12 bytes
   ```

   The secret have the Type: Opaque defined, so you need to inspect the yaml of
   the secret itself to see the content of those keys:

   ```console
   > oc get secret router-stats-default -o yaml | awk '/Username|Password/ && !/f:/'
     statsPassword: Y0dGemMyWm5kbTVu
     statsUsername: ZFhObGNtMW5jbmh3
   ```

4. Check HAProxy port by pointing directly to crc IP:

   ```console
   > curl $(crc ip):1936/healthz
   ok
   ```
