# Exercise 008 - Create a new user in your local OpenShift - Solutions

1) Log into OCP with kubeadmin:

> oc login -u kubeadmin
Logged into "https://api.crc.testing:6443" as "kubeadmin" using existing credentials.
...

In crc we have this default OAuth

> oc get oauth cluster -o yaml
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

2) The secret is:

> oc get -n openshift-config secret htpass-secret
NAME            TYPE     DATA   AGE
htpass-secret   Opaque   1      13d

> oc get -n openshift-config secret htpass-secret -o yaml
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

The secret is a base64 string that contains the htpasswd file.
This is how to decode it:

> echo ZGV2ZWxvcGVyOiQyYSQxMCQ3ME5qeXpzN2Q4QnhyNm10VXBISTR1elRjdHpxU3BUUGxBR29kclg4S1U2cmJTTkxBY05zZQprdWJlYWRtaW46JDJhJDEwJGRmL0Vrck9uZlI3UkhRcVp0dW5Bc3VKZTd4SGc3aGhSaEZwVmRhWTNjcGJCOEl5OGZFZmw2 | base64 --decode
developer:$2a$10$70Njyzs7d8Bxr6mtUpHI4uzTctzqSpTPlAGodrX8KU6rbSNLAcNse
kubeadmin:$2a$10$df/EkrOnfR7RHQqZtunAsuJe7xHg7hhRhFpVdaY3cpbB8Iy8fEfl6

3) To download the file locally you can use 'oc extract':

> oc -n openshift-config extract secret/htpass-secret -n openshift-config --to . --confirm
htpasswd

4) To locally manipulate the htpasswd file you'll need the htpasswd command
which is availabe in the httpd-tools package:

> yum -y install httpd-tools

Then you can add a user:

> htpasswd -B htpasswd myuser
New password: 
Re-type new password: 
Adding password for user myuser

Be careful on the content of the file:

> cat htpasswd 
developer:$2a$10$70Njyzs7d8Bxr6mtUpHI4uzTctzqSpTPlAGodrX8KU6rbSNLAcNse
kubeadmin:$2a$10$df/EkrOnfR7RHQqZtunAsuJe7xHg7hhRhFpVdaY3cpbB8Iy8fEfl6myuser:$2y$05$4Mgz9BXGY.CxHn2lsIuvPeZi.lhZmb3SRAUPsGepwgJlWTwYv/mOm

By default there's no carriage return, so the new name is not appended on a
new line, so you'll need to edit manually and get this result:

> cat htpasswd 
developer:$2a$10$70Njyzs7d8Bxr6mtUpHI4uzTctzqSpTPlAGodrX8KU6rbSNLAcNse
kubeadmin:$2a$10$df/EkrOnfR7RHQqZtunAsuJe7xHg7hhRhFpVdaY3cpbB8Iy8fEfl6
myuser:$2y$05$4Mgz9BXGY.CxHn2lsIuvPeZi.lhZmb3SRAUPsGepwgJlWTwYv/mOm

Once you're done, you can push back the new file in the secret:

> oc -n openshift-config set data secret/htpass-secret --from-file htpasswd=./htpasswd -n openshift-config
secret/htpass-secret data updated

5) Check the login:

> oc login -u myuser
Authentication required for https://api.crc.testing:6443 (openshift)
Username: myuser
Password: 
Login failed (401 Unauthorized)
Verify you have provided correct credentials.

It doesn't work, because we need to create an internal OCP user that will be
mapped to the one created in the secret:

> oc get users
NAME        UID                                    FULL NAME   IDENTITIES
developer   caa355c8-c867-4397-b9df-78d7a3ad3ca6               developer:developer
kubeadmin   2f07aa13-30f9-4db0-8aa5-c1e546f5196e               developer:kubeadmin

> oc create user myuser
user.user.openshift.io/myuser created

Finally you'll be able to login with the new user:

> oc login -u myuser
Authentication required for https://api.crc.testing:6443 (openshift)
Username: myuser
Password: 
Login successful.

You don't have any projects. You can try to create a new project, by running

    oc new-project <projectname>

> oc get users
NAME        UID                                    FULL NAME   IDENTITIES
developer   caa355c8-c867-4397-b9df-78d7a3ad3ca6               developer:developer
kubeadmin   2f07aa13-30f9-4db0-8aa5-c1e546f5196e               developer:kubeadmin
rasca       48ea9309-8e3c-44ab-94ee-0b16e1e5833b               developer:rasca

The user is by default part of the developer identity, which means that can
create new projects.
