# Lab | Kubernetes Playing With Roles

In this lab you will:

1. Check which cluster role can be assigned to `myuser` so that it will be
   possible for the user to view all the resources.
2. Assign the discovered cluster role to the user and check whether it works.
3. Define a new role named `deploy-creator` that will make `myuser` able to
   create deployments in `myns` namespace.
4. Try to create a new deployment in `myns` namespace.

## Solution

1. Ensure you are using the right context named `minikube`:

   ```console
   $ kubectl config use-context minikube
   Switched to context "minikube".
   ```

   Check something about `view` in cluster roles:

   ```console
   $ kubectl get clusterroles | grep view
   system:aggregate-to-view                                               2022-12-05T14:28:56Z
   system:public-info-viewer                                              2022-12-05T14:28:56Z
   view                                                                   2022-12-05T14:28:56Z

   $ kubectl describe clusterrole view
   Name:         view
   Labels:       kubernetes.io/bootstrapping=rbac-defaults
                 rbac.authorization.k8s.io/aggregate-to-edit=true
   Annotations:  rbac.authorization.kubernetes.io/autoupdate: true
   PolicyRule:
     Resources                                    Non-Resource URLs  Resource Names  Verbs
     ---------                                    -----------------  --------------  -----
     bindings                                     []                 []              [get list watch]
     configmaps                                   []                 []              [get list watch]
     ...
     poddisruptionbudgets.policy/status           []                 []              [get list watch]
     poddisruptionbudgets.policy                  []                 []              [get list watch]
   ```

2. So the `view` cluster role can be assigned to `myuser` via role binding:

   ```console
   $ kubectl create clusterrolebinding view-to-myuser --clusterrole=view --user=myuser
   clusterrolebinding.rbac.authorization.k8s.io/view-to-myuser created
   ```

   Now, by using the `myuser@minikube` context it should be possible to get the
   resources for both namespace `myns` (which is empty right now) and the entire
   cluster:

   ```console
   $ kubectl config use-context myuser@minikube
   Switched to context "myuser@minikube".

   $ kubectl --namespace myns get all
   No resources found in myns namespace.

   $ kubectl get all -A
   NAMESPACE     NAME                                   READY   STATUS    RESTARTS      AGE
   kube-system   pod/coredns-565d847f94-7rkwx           1/1     Running   3 (42m ago)   124m
   kube-system   pod/etcd-minikube                      1/1     Running   4 (42m ago)   125m
   kube-system   pod/kube-apiserver-minikube            1/1     Running   3 (43m ago)   125m
   kube-system   pod/kube-controller-manager-minikube   1/1     Running   3 (42m ago)   125m
   kube-system   pod/kube-proxy-dstd5                   1/1     Running   4 (42m ago)   124m
   kube-system   pod/kube-scheduler-minikube            1/1     Running   3 (43m ago)   125m
   kube-system   pod/storage-provisioner                1/1     Running   5 (43m ago)   125m

   NAMESPACE     NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
   default       service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP                  125m
   kube-system   service/kube-dns     ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP,9153/TCP   125m

   NAMESPACE     NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
   kube-system   daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   125m

   NAMESPACE     NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
   kube-system   deployment.apps/coredns   1/1     1            1           125m

   NAMESPACE     NAME                                 DESIRED   CURRENT   READY   AGE
   kube-system   replicaset.apps/coredns-565d847f94   1         1         1       124m
   ```

3. The user `myuser` is able to view everything, but not to create anything in
   its namespace:

   ```console
   $ kubectl config current-context
   myuser@minikube

   $ kubectl --namespace myns create deployment nginx --image=nginx:latest
   error: failed to create deployment: deployments.apps is forbidden: User "myuser" cannot create resource "deployments" in API group "apps" in the namespace "myns"
   ```

   Move back to admin user and define a role that will make it possible for
   `myuser` to create, delete and update resources like pods, replicaset and
   deployments in the `myns` namespace:

   ```console
   $ kubectl config use-context minikube
   Switched to context "minikube".

   $ kubectl --namespace myns create role deploy-creator \
       --verb=create,delete,update \
       --resource=pods,replicaset,deployments
   role.rbac.authorization.k8s.io/deploy-creator created
   ```

   Bind the new role to the user:

   ```console
   $ kubectl --namespace=myns create rolebinding deploy-creator-to-myuser \
       --role=deploy-creator \
       --user=myuser
   rolebinding.rbac.authorization.k8s.io/deploy-creator-to-myuser created
   ```

4. Now it should be possible to create (and delete) a new deployment as
   `myuser`:

   ```console
   $ kubectl config use-context myuser@minikube
   Switched to context "myuser@minikube".

   $ kubectl --namespace myns create deployment nginx --image=nginx:latest
   deployment.apps/nginx created

   $ kubectl --namespace myns get all
   NAME                         READY   STATUS              RESTARTS   AGE
   pod/nginx-6d666844f6-8j42s   0/1     ContainerCreating   0          6s

   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   0/1     1            0           6s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         0       6s

   $ kubectl --namespace myns get all
   NAME                         READY   STATUS    RESTARTS   AGE
   pod/nginx-6d666844f6-8j42s   1/1     Running   0          39s

   NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
   deployment.apps/nginx   1/1     1            1           39s

   NAME                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/nginx-6d666844f6   1         1         1       39s

   $ kubectl --namespace myns delete deployment nginx
   deployment.apps "nginx" deleted

   $ kubectl --namespace myns get all
   No resources found in myns namespace.
   ```
