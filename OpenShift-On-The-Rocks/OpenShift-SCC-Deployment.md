# Lab | Explore current SCC and add more permissions to a deployment

In this lab you will:

1. As `kubeadmin`, look at available SCCs and explore some details (like
   `anyuid`, `privileged` and `restricted`).
2. As `developer` try deploying a new app inside a new project named `scc-test`
   based on a container which require root privileges (like the `nginx:latest`
   docker-image).
3. Show logs and see why the pod can't run.
4. Create a new ServiceAccount named `useroot`.
5. As `kubeadmin` use the `add-scc-to-user` policy to add `anyuid` SCC to
   `useroot` service account.
6. Then, as `developer`, edit the `nginx` deployment to add `useroot` as
   `serviceAccountName` attribute inside `spec:template:spec:` attribute;
7. Check the new status of the deployment and look at logs to show if pods are
   running correctly;

## Solution

1. First login as 'kubeadmin':

   ```console
   $ oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ...
   ```

   Than take a look at the available scc:

   ```console
   $ oc get scc
   NAME               PRIV      CAPS      SELINUX     RUNASUSER          FSGROUP     SUPGROUP    PRIORITY   READONLYROOTFS   VOLUMES
   anyuid             false     []        MustRunAs   RunAsAny           RunAsAny    RunAsAny    10         false            [configMap downwardAPI emptyDir persistentVolumeClaim projected secret]
   ...
   ```

   And specifically on 'anyuid', 'privileged', 'restricted':

   ```console
   $ oc describe scc/anyuid
   Name:                              anyuid
   Priority:                          10
   Access:
     Users:                           <none>
     Groups:                          system:cluster-admins
   Settings:
     Allow Privileged:                false
     Allow Privilege Escalation:      true
     Default Add Capabilities:        <none>
     Required Drop Capabilities:      MKNOD
     Allowed Capabilities:            <none>
     Allowed Seccomp Profiles:        <none>
     Allowed Volume Types:            configMap,downwardAPI,emptyDir,persistentVolumeClaim,projected,secret
     Allowed Flexvolumes:             <all>
     Allowed Unsafe Sysctls:          <none>
     Forbidden Sysctls:               <none>
     Allow Host Network:              false
     Allow Host Ports:                false
     Allow Host PID:                  false
     Allow Host IPC:                  false
     Read Only Root Filesystem:       false
     Run As User Strategy: RunAsAny
       UID:                           <none>
       UID Range Min:                 <none>
       UID Range Max:                 <none>
     SELinux Context Strategy: Must   RunAs
       User:                          <none>
       Role:                          <none>
       Type:                          <none>
       Level:                         <none>
     FSGroup Strategy: RunAsAny
       Ranges:                        <none>
     Supplemental Groups Strategy: RunAsAny
       Ranges:                        <none>
   $ oc describe scc/privileged
   ...

   $ oc describe scc/restricted
   ...
   ```

2. Become 'developer':

   ```console
   $ oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...
   ```

   And create 'scc-test' project:

   ```console
   $ oc new-project scc-test
   Now using project "scc-test" on server "https://api.crc.testing:6443".
   ...
   ```

   To specifically use the 'nginx' image from the 'docker-image' you'll need to
   use the '--docker-image=' switch:

   ```console
   $ oc new-app --name=nginx --docker-image=nginx:latest
   --> Found container image 4cdc5dd (8 days old) from Docker Hub for "nginx:latest"
   ...
   ```

3. Check the status:

   ```console
   $ oc status
   svc/nginx - 10.217.5.66:80
     deployment/nginx deploys istag/nginx:latest
       deployment #2 running for 42 seconds - 0/1 pods (warning: 2 restarts)
       deployment #1 deployed 44 seconds ago - 0/1 pods growing to 1

   Errors:
     * pod/nginx-7c9657fbc6-trf5h is crash-looping

   1 error, 1 info identified, use 'oc status --suggest' to see details.

   $ oc logs nginx-1-nwhqs -c nginx
   /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
   /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
   10-listen-on-ipv6-by-default.sh: info: can not modify /etc/nginx/conf.d/default.conf (read-only file system?)
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
   /docker-entrypoint.sh: Configuration complete; ready for start up
   2021/07/15 10:55:33 [warn] 1#1: the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
   nginx: [warn] the "user" directive makes sense only if the master process runs with super-user privileges, ignored in /etc/nginx/nginx.conf:2
   2021/07/15 10:55:33 [emerg] 1#1: mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
   nginx: [emerg] mkdir() "/var/cache/nginx/client_temp" failed (13: Permission denied)
   ```

   So we have a permission problem. This happens because the image requires high
   privileges to work properly.

4. Become 'kubeadmin' again:

   ```console
   $ oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials
   ```

   Then you can create the 'useroot' serviceaccount:

   ```console
   $ oc create serviceaccount useroot
   serviceaccount/useroot created
   ```

5. Use 'oc adm policy add-scc-to-user' to associate 'useroot' service account
   to the 'anyuid' scc:

   ```console
   $ oc whoami
   kubeadmin

   $ oc adm policy add-scc-to-user anyuid --serviceaccount useroot
   clusterrole.rbac.authorization.k8s.io/system:openshift:scc:anyuid added: "useroot"
   ```

6. Become 'developer' again:

   ```console
   $ oc login -u developer
   Logged into "https://api.crc.testing:6443" as "developer" using existing credentials.
   ...

   $ oc project scc-test
   Now using project "scc-test" on server "https://192.168.42.154:8443".
   ```

   There are two ways for adding the attribute, by using 'oc edit deployment':

   ```console
   $ oc edit deployment nginx
   (vim interface opens)
   ```

   And add the 'serviceAccountName:' attribute inside 'spec:template:spec:'
   attribute:

   ```yaml
      ...
      spec:
        ...
         template:
          ...
            spec:
            ...
            serviceAccountName: useroot
            ...
   ```

   ```console
   deploymentconfig.apps.openshift.io/nginx edited
   ```

   Or by using the 'oc patch' command like this:

   ```console
   $ oc patch deployment nginx --patch '{"spec":{"template":{"spec":{"serviceAccountName": "useroot"}}}}'
   deployment.apps/nginx patched
   ```

7. Check the status via 'oc status':

   ```console
   $ oc status
   In project scc-test on server https://api.crc.testing:6443

   svc/nginx - 10.217.5.66:80
     deployment/nginx deploys istag/nginx:latest
       deployment #3 running for 28 seconds - 1 pod
       deployment #2 deployed 4 minutes ago
       deployment #1 deployed 4 minutes ago
   1 info identified, use 'oc status --suggest' to see details.
   ```

   Check pods:

   ```console
   $ oc get pods
   NAME                    READY   STATUS    RESTARTS   AGE
   nginx-bdb8f978d-498jh   1/1     Running   0          53m
   ```

   And finally check logs:

   ```console
   $ oc logs pod/nginx-bdb8f978d-498jh -c nginx
   /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
   /docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
   10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
   10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
   /docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
   /docker-entrypoint.sh: Configuration complete; ready for start up
   2021/07/15 10:58:37 [notice] 1#1: using the "epoll" event method
   2021/07/15 10:58:37 [notice] 1#1: nginx/1.21.1
   2021/07/15 10:58:37 [notice] 1#1: built by gcc 8.3.0 (Debian 8.3.0-6)
   2021/07/15 10:58:37 [notice] 1#1: OS: Linux 4.18.0-240.22.1.el8_3.x86_64
   2021/07/15 10:58:37 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
   2021/07/15 10:58:37 [notice] 1#1: start worker processes
   2021/07/15 10:58:37 [notice] 1#1: start worker process 32
   2021/07/15 10:58:37 [notice] 1#1: start worker process 33
   2021/07/15 10:58:37 [notice] 1#1: start worker process 34
   2021/07/15 10:58:37 [notice] 1#1: start worker process 35
   ```

   Cleanup:

   ```console
   $ oc delete project scc-test
   project.project.openshift.io "scc-test" deleted
   ```
