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
6. Fix the problems by creating a label for the pod and a service for the
   backend.
7. Check that now the web page shows the initial Wordpress configuration page
   correctly (and so it connects to the DB).
8. Delete the `backend` service and create it from a yaml file.
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
   $ kubectl -n fe-be-test run \
       --image mariadb \
       --env MYSQL_DATABASE=mywpdb \
       --env MYSQL_USER=mywpuser \
       --env MYSQL_PASSWORD=mywppass \
       --env MYSQL_RANDOM_ROOT_PASSWORD='1' \
       backend
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
   $ kubectl -n fe-be-test run \
       --image wordpress:latest \
       --env WORDPRESS_DB_HOST=backend \
       --env WORDPRESS_DB_USER=mywpuser \
       --env WORDPRESS_DB_PASSWORD=mywppass \
       --env WORDPRESS_DB_NAME=mywpdb \
       frontend
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
   $ sudo yum -y install yum-utils
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

6. Service will rely on the pod label for the `selector`, so we need to use an
   existing one (check by using `kubectl -n fe-be-test describe pod backend`) or
   creating a new one:

   ```console
   $ kubectl -n fe-be-test label pod backend name=backend
   pod/backend labeled
   ```

   Then it is time to create the service, and this can be done by creating a
   service object named `backend` that expose the tcp 3306 port targeting the
   `3306` port and applying its selector to the label named `name` with value
   `backend`:

   ```console
   $ kubectl -n fe-be-test create service clusterip backend --tcp=3306:3306
   service/backend created

   $ kubectl -n fe-be-test set selector service backend 'name=backend'
   service/backend selector updated
   ```

   Alternatively, the `kubectl expose` command can be used as follows:

   ```console
   $ kubectl -n fe-be-test expose pod backend \
       --name=backend \
       --port=3306 \
       --selector="name=backend"
   service/frontend exposed
   ```

   In either cases the result will be something like this:

   ```console
   $ kubectl -n fe-be-test get service backend
   NAME      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
   backend   ClusterIP   10.96.16.80   <none>        3306/TCP   26s
   ```

7. With the solution in place we can see the expected output:

   ```console
   $ lynx localhost:8080 -dump
      WordPress
      Select a default language [English (United States)__________]

      Continue
   ```

8. To manually create the service it is possible to use `kubectl expose` to
   generate the yaml and use with `kubectl create`:

   ```console
   $ kubectl -n fe-be-test delete service backend
   service "backend" deleted

   $ kubectl -n fe-be-test expose pod backend \
       --name=backend \
       --port=3306 \
       --selector="name=backend" \
       --dry-run=client \
       -o yaml > svc_backend.yaml

   $ cat svc_backend.yaml
   apiVersion: v1
   kind: Service
   metadata:
     creationTimestamp: null
     labels:
       name: backend
       run: backend
     name: backend
     namespace: fe-be-test
   spec:
     ports:
     - port: 3306
       protocol: TCP
       targetPort: 3306
     selector:
       name: backend
   status:
     loadBalancer: {}

   $ kubectl create -f svc_backend.yaml
   service/backend created

   $ lynx localhost:8080 -dump
      WordPress
      Select a default language [English (United States)__________]

      Continue
   ```

   The main difference in this approach is that we can put the yaml file under
   version control to track any modification, using a real **Infrastructure as Code**
   approach.

9. You can then safely remove the namespace:

   ```console
   $ kubectl delete namespace fe-be-test
   namespace "fe-be-test" deleted
   ```
