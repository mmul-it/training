# Lab | Kubernetes New User

In this lab you will:

1. Create a namespace `myns` for the user named `myuser`.
2. Using `openssl` create a certificate key for the user.
3. Using `openssl` and the minikube certificate sign the certificate.
4. Add user context to the minkube config.
5. Try to use `myuser` to get all the resources in the `myns` namespace.

## Solution

1. Create the namespace:

   ```console
   $ kubectl create namespace myns
   namespace/myns created
   ```

2. Use `openssl` to create the key:

   ```console
   $ openssl genrsa -out ./myuser.key 2048

   $ ls ./myuser.key
   ./myuser.key
   ```

3. Use `openssl` to sign, using the CA located in `.minikube/ca.crt`:

   ```console
   $ openssl req -new -key myuser.key -out myuser.csr -subj "/CN=myuser/O=myns"

   $ ls myuser.csr
   myuser.csr

   $ openssl x509 -req -in myuser.csr -CA .minikube/ca.crt -CAkey .minikube/ca.key -CAcreateserial -out myuser.crt -days 365
   Certificate request self-signature ok
   subject=CN = myuser, O = myns\C3\A2\C2\80\C2\8B
   ```

4. User can now be added by first creating the context:

   ```console
   $ kubectl config set-context myuser@minikube \
       --cluster=minikube \
       --user=myuser \
       --namespace=myns
   Context "myuser@minikube" created.
   ```

   And then by adding the credentials:

   ```console
   $ kubectl config set-credentials myuser --client-certificate=./myuser.crt --client-key=./myuser.key
   User "myuser" set.
   ```

5. Using the new context:

   ```console
   $ kubectl config use-context myuser@minikube
   Switched to context "myuser@minikube".
   ```

   We can try to get all the resources in namespace `myns`:

   ```console
   $ kubectl --namespace myns get all
   Error from server (Forbidden): pods is forbidden: User "myuser" cannot list resource "pods" in API group "" in the namespace "myns"
   Error from server (Forbidden): replicationcontrollers is forbidden: User "myuser" cannot list resource "replicationcontrollers" in API group "" in the namespace "myns"
   Error from server (Forbidden): services is forbidden: User "myuser" cannot list resource "services" in API group "" in the namespace "myns"
   Error from server (Forbidden): daemonsets.apps is forbidden: User "myuser" cannot list resource "daemonsets" in API group "apps" in the namespace "myns"
   Error from server (Forbidden): deployments.apps is forbidden: User "myuser" cannot list resource "deployments" in API group "apps" in the namespace "myns"
   Error from server (Forbidden): replicasets.apps is forbidden: User "myuser" cannot list resource "replicasets" in API group "apps" in the namespace "myns"
   Error from server (Forbidden): statefulsets.apps is forbidden: User "myuser" cannot list resource "statefulsets" in API group "apps" in the namespace "myns"
   Error from server (Forbidden): horizontalpodautoscalers.autoscaling is forbidden: User "myuser" cannot list resource "horizontalpodautoscalers" in API group "autoscaling" in the namespace "myns"
   Error from server (Forbidden): cronjobs.batch is forbidden: User "myuser" cannot list resource "cronjobs" in API group "batch" in the namespace "myns"
   Error from server (Forbidden): jobs.batch is forbidden: User "myuser" cannot list resource "jobs" in API group "batch" in the namespace "myns"
   ```

   As you can see, there's no way (yet) to get anything, because we did'nt defined a role, but the fact that we received a `forbidden` means we were able to login with the newly created certificate.
