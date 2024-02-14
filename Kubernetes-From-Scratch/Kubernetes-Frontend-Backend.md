# Lab | Kubernetes Frontend Backend

In this lab you will:

1. Create a namespace named `fe-be-test`.
2. Create a new pod named `backend` based upon the `mariadb:latest` image inside
   namespace `fe-be-test`, passing these environmental variables:
   - `MYSQL_DATABASE`: mywpdb
   - `MYSQL_USER`: mywpuser
   - `MYSQL_PASSWORD`: mywppass
   - `MYSQL_RANDOM_ROOT_PASSWORD`: '1'
3. Create a new pod named `frontend` based upon the `wordpress:latest` image
   inside namespace `fe-be-test`, passing these environmental variables:
   - `WORDPRESS_DB_HOST`: backend
   - `WORDPRESS_DB_USER`: mywpuser
   - `WORDPRESS_DB_PASSWORD`: mywppass
   - `WORDPRESS_DB_NAME`: mywpdb
4. Install the `lynx` tool to check rendered http pages from command line.
5. Using `kubectl -n fe-be-test port-forward frontend 8080:80` expose locally
   the port of the frontend and check the status of wordpress with lynx: what is
   the problem? Why it is not working?
6. Fix the problems by creating a service for the backend, labeling the pod and
   set the selector for the service.
7. Check that now the web page shows the initial Wordpress configuration page
   correctly (and so it connects to the DB).
8. Expose a pod quickly and easily.
9. Delete `fe-be-test` namespace.

## Solution

1. Create the namespace:

   ```console
   $ kubectl create namespace fe-be-test
   namespace/fe-be-test created
   ```

2. Create the pod by using `kubectl run` with a `--env` for each environmental
   variable:

   ```console
   $ kubectl run -n fe-be-test --image mariadb --env MYSQL_DATABASE=mywpdb --env MYSQL_USER=mywpuser --env MYSQL_PASSWORD=mywppass --env MYSQL_RANDOM_ROOT_PASSWORD='1' backend
   pod/backend created

   $ kubectl -n fe-be-test get pods
   NAME      READY   STATUS              RESTARTS   AGE
   backend   0/1     ContainerCreating   0          19s

   $ kubectl -n fe-be-test get pods
   NAME      READY   STATUS    RESTARTS   AGE
   backend   1/1     Running   0          42s
   ```

3. Do the same for the frontend:

   ```console
   $ kubectl run -n fe-be-test --image wordpress:latest --env WORDPRESS_DB_HOST=backend --env WORDPRESS_DB_USER=mywpuser --env WORDPRESS_DB_PASSWORD=mywppass --env WORDPRESS_DB_NAME=mywpdb frontend
   pod/frontend created

   $ kubectl -n fe-be-test get pods
   NAME       READY   STATUS              RESTARTS   AGE
   backend    1/1     Running             0          102s
   frontend   0/1     ContainerCreating   0          6s

   $ kubectl -n fe-be-test get pods -w
   NAME       READY   STATUS    RESTARTS   AGE
   backend    1/1     Running   0          14s
   frontend   1/1     Running   0          6s
   ```

4. Install the `lynx` tool, using for Debian based systems:

   ```console
   $ sudo apt-get install -y lynx
   ...
   The following NEW packages will be installed:
     lynx lynx-common
   ...
   ```

   And for RHEL based systems:

   ```console
   $ sudo yum install yum-utils
   ...

   $ sudo yum config-manager --set-enabled powertools
   (no output)

   $ sudo yum -y install lynx
   ...
   ```

5. Open the `8080` port using `kubectl port-forward`:

   ```console
   $ kubectl -n fe-be-test port-forward frontend 8080:80
   Forwarding from 127.0.0.1:8080 -> 80
   Forwarding from [::1]:8080 -> 80
   ```

   And froma another terminal use `lynx` to catch the problem:

   ```console
   $ lynx localhost:8080 -dump
   Error establishing a database connection
   ```

   Wordpress can't contact the `backend` pod, even if it is up and running.
   So pods within the same namespace can't contact each other by name, we need
   a service.

6. We are going to do three different actions:
   - Create a service named `backed` that expose the tcp 3306 port targeting the
     `3306` port:

     ```console
     $ kubectl -n fe-be-test create service clusterip backend --tcp=3306:3306
     service/backend created
     ```

   - Label the existing `backend` pod with a label named `name` with value
     `backend`:

     ```console
     $ kubectl -n fe-be-test label pod backend name=backend
     pod/backend labeled
     ```

   - Set the selector over the previously created label in the service:

     ```console
     $ kubectl -n fe-be-test set selector service backend 'name=backend'
     service/backend selector updated
     ```

7. With the solution in place we can see the expected output:

   ```console
   $ lynx localhost:8080 -dump
      WordPress
      Select a default language [English (United States)__________]

      Continue
   ```

8. Expose a pod (and not only) in a quick and easy way.

   ```console
   $ kubectl expose pod nginx \
       --name=frontend \
       --port=80 \
       --selector="name=frontend" \
       --dry-run=client \
       -o yaml > svc_frontend.yaml

   $ kubectl create -f svc_frontend.yaml
   ```

   Note that we could have exposed the service directly, but it's not a best practise. 

9. You can then safely remove the namespace:

   ```console
   $ kubectl delete namespace fe-be-test
   namespace "fe-be-test" deleted
   ```
