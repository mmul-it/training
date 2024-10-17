# Lab | Create a new user in your local OpenShift

In this lab you will:

1. As user `kubeadmin` check the oauth default configuration for crc.
2. Identify the secret associated with the default authentication.
3. Download the secret to a local file using `oc extract`.
4. Add a user using 'htpasswd' and push the newly created file to the secret.
5. Check if you can login (you should not) and create the crc user so that
   you'll be able to login properly.

## Solution

1. Log into OCP with 'kubeadmin':

   ```console
   $ oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
   ...
   ```

   In crc we have this default OAuth:

   ```console
   $ oc get oauth cluster -o yaml
   apiVersion: config.openshift.io/v1
   kind: OAuth
   metadata:
   ...
   ...
   spec:
     identityProviders:
     - htpasswd:
         fileData:
           name: htpass-secret
       mappingMethod: claim
       name: developer
       type: HTPasswd
     templates:
       login:
         name: login-template
     tokenConfig:
       accessTokenMaxAgeSeconds: 0
   ```

2. The secret is:

   ```console
   $ oc get -n openshift-config secret htpass-secret
   NAME            TYPE     DATA   AGE
   htpass-secret   Opaque   1      13d

   $ oc get -n openshift-config secret htpass-secret -o yaml
   apiVersion: v1
   data:
     htpasswd: ZGV2ZWxvcGVyOiQyYSQxMCQ3ME5qeXpzN2Q4QnhyNm10VXBISTR1elRjdHpxU3BUUGxBR29kclg4S1U2cmJTTkxBY05zZQprdWJlYWRtaW46JDJhJDEwJGRmL0Vrck9uZlI3UkhRcVp0dW5Bc3VKZTd4SGc3aGhSaEZwVmRhWTNjcGJCOEl5OGZFZmw2
   kind: Secret
   metadata:
   ...
     name: htpass-secret
     namespace: openshift-config
   ...
   type: Opaque
   ```

   The secret is a base64 string that contains the htpasswd file.
   This is how to decode it:

   ```console
   $ echo ZGV2ZWxvcGVyOiQyYSQxMCQ3ME5qeXpzN2Q4QnhyNm10VXBISTR1elRjdHpxU3BUUGxBR29kclg4S1U2cmJTTkxBY05zZQprdWJlYWRtaW46JDJhJDEwJGRmL0Vrck9uZlI3UkhRcVp0dW5Bc3VKZTd4SGc3aGhSaEZwVmRhWTNjcGJCOEl5OGZFZmw2 | base64 --decode
   developer:$2a$10$70Njyzs7d8Bxr6mtUpHI4uzTctzqSpTPlAGodrX8KU6rbSNLAcNse
   kubeadmin:$2a$10$df/EkrOnfR7RHQqZtunAsuJe7xHg7hhRhFpVdaY3cpbB8Iy8fEfl6
   ```

3. To download the file locally you can use 'oc extract':

   ```console
   $ oc -n openshift-config extract secret/htpass-secret -n openshift-config --to . --confirm
   htpasswd
   ```

4. To locally manipulate the htpasswd file you'll need the `htpasswd` command
   which is availabe in the httpd-tools package on RHEL based system (install it
   with `sudo yum -y install httpd-tools`) and in the `apache2-utils` package on
   Debian based systems (`sudo apt -y install apache2-utils`).

   Then you can add a user:

   ```console
   $ htpasswd -B htpasswd myuser
   New password:
   Re-type new password:
   Adding password for user myuser
   ```

   Be careful on the content of the file:

   ```console
   $ cat htpasswd
   developer:$2a$10$70Njyzs7d8Bxr6mtUpHI4uzTctzqSpTPlAGodrX8KU6rbSNLAcNse
   kubeadmin:$2a$10$df/EkrOnfR7RHQqZtunAsuJe7xHg7hhRhFpVdaY3cpbB8Iy8fEfl6myuser:$2y$05$4Mgz9BXGY.CxHn2lsIuvPeZi.lhZmb3SRAUPsGepwgJlWTwYv/mOm
   ```

   By default there's no carriage return, so the new name is not appended on a
   new line, so you'll need to edit manually and get this result:

   ```console
   $ cat htpasswd
   developer:$2a$10$70Njyzs7d8Bxr6mtUpHI4uzTctzqSpTPlAGodrX8KU6rbSNLAcNse
   kubeadmin:$2a$10$df/EkrOnfR7RHQqZtunAsuJe7xHg7hhRhFpVdaY3cpbB8Iy8fEfl6
   myuser:$2y$05$4Mgz9BXGY.CxHn2lsIuvPeZi.lhZmb3SRAUPsGepwgJlWTwYv/mOm
   ```

   Once you're done, you can push back the new file in the secret:

   ```console
   $ oc -n openshift-config set data secret/htpass-secret --from-file htpasswd=./htpasswd
   secret/htpass-secret data updated
   ```

   The secret's update will be monitored by the `openshift-authentication`
   operator that will take care of recreating the `oauth-openshift` pod.

   After the update the `openshift-authentication` namespace should be monitored
   to check when the `oauth-openshift` pod is deployed with the new settings:

   ```console
   $ oc -n openshift-authentication get pods
   NAME                               READY   STATUS    RESTARTS   AGE
   oauth-openshift-5d8c8857fb-c6nrq   1/1     Running   0          5s
   ```

   It can take up to 5 minutes for the update to happen.

5. The above operation should be enough to make the login work:

   ```console
   $ oc login -u myuser
   Authentication required for https://api.crc.testing:6443 (openshift)
   Username: myuser
   Password:
   Login successful.

   You don't have any projects. You can try to create a new project, by running

       oc new-project <projectname>
   ```

   If the login doesn't work, the user creation can be forced to map the
   internal OCP user with the one created in the secret:

   ```console
   $ oc login -u kubeadmin
   Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.

   $ oc get users
   NAME        UID                                    FULL NAME   IDENTITIES
   developer   caa355c8-c867-4397-b9df-78d7a3ad3ca6               developer:developer
   kubeadmin   2f07aa13-30f9-4db0-8aa5-c1e546f5196e               developer:kubeadmin

   $ oc create user myuser
   user.user.openshift.io/myuser created
   ```

   The final result in any case will be this one:

   ```console
   $ oc get users
   NAME        UID                                    FULL NAME   IDENTITIES
   developer   caa355c8-c867-4397-b9df-78d7a3ad3ca6               developer:developer
   kubeadmin   2f07aa13-30f9-4db0-8aa5-c1e546f5196e               developer:kubeadmin
   myuser      48ea9309-8e3c-44ab-94ee-0b16e1e5833b               developer:myuser
   ```

   The user is by default part of the developer identity, which means that can
   create new projects.
