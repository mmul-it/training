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
   STATS_PASSWORD_FILE:                       /var/lib/haproxy/conf/metrics-auth/statsPassword
   STATS_PORT:                                1936
   STATS_USERNAME_FILE:                       /var/lib/haproxy/conf/metrics-auth/statsUsername
   ```

3. Extract username and password by looking into the content of the files
   inside the container:

   ```console
   > oc exec router-default-8475b74568-zdwjm -- cat /var/lib/haproxy/conf/metrics-auth/statsUsername
   dXNlcmJqNXE0

   > oc exec router-default-8475b74568-zdwjm -- cat /var/lib/haproxy/conf/metrics-auth/statsPassword
   cGFzc2dqYmc1
   ```

4. Check HAProxy port by pointing directly to crc IP:

   ```console
   > curl $(crc ip):1936/healthz
   ok
   ```
