# Exercise | Kubernetes Frontend Backend | Solution

1. Create the namespace:

   ```console
   > kubectl create namespace fe-be-test
   namespace/fe-be-test created
   ```

2. Create the pod by using `kubectl run` with a `--env` for each environmental variable:

   ```console
   > kubectl run -n fe-be-test --image mariadb --env MYSQL_DATABASE=mywpdb --env MYSQL_USER=mywpuser --env MYSQL_PASSWORD=mywppass --env MYSQL_RANDOM_ROOT_PASSWORD='1' backend
   pod/backend created
   
   > kubectl -n fe-be-test get pods
   NAME      READY   STATUS              RESTARTS   AGE
   backend   0/1     ContainerCreating   0          19s
   
   > kubectl -n fe-be-test get pods
   NAME      READY   STATUS    RESTARTS   AGE
   backend   1/1     Running   0          42s
   ```

3. Do the same for the frontend:

   ```console
   > kubectl run -n fe-be-test --image wordpress:latest --env WORDPRESS_DB_HOST=backend --env WORDPRESS_DB_USER=mywpuser --env WORDPRESS_DB_PASSWORD=mywppass --env WORDPRESS_DB_NAME=mywpdb frontend
   pod/frontend created
   
   > kubectl -n fe-be-test get pods
   NAME       READY   STATUS              RESTARTS   AGE
   backend    1/1     Running             0          102s
   frontend   0/1     ContainerCreating   0          6s
   
   > kubectl -n fe-be-test get pods -w
   NAME       READY   STATUS    RESTARTS   AGE
   backend    1/1     Running   0          14s
   frontend   1/1     Running   0          6s
   ```

4. Insall the `lynx` tool:

   ```console
   > sudo apt-get install -y lynx
   ...
   The following NEW packages will be installed:
     lynx lynx-common
   ...
   ```

5. Open the port-forward and use `lynx` to see the problem:

   ```console
   > kubectl -n fe-be-test port-forward frontend 8080:80
   Forwarding from 127.0.0.1:8080 -> 80
   Forwarding from [::1]:8080 -> 80
   
   > sudo apt-get install -y lynx
   > lynx localhost:8080 -dump
   Error establishing a database connection
   ```

   The problem is that Wordpress can't contact the `backend` pod, even if it is up and running. So pods within the same namespace can't contact each other by name, we need a service.

6. We are going to do three different actions:
   - Create a service named `backed` that expose the tcp 3306 port targeting the 3306 port:

     ```console
     > kubectl -n fe-be-test create service clusterip backend --tcp=3306:3306
     service/backend created
     ```

   - Label the existing `backend` pod with a label named `name` with value `backend`:

     ```console 
     > kubectl -n fe-be-test label pod backend name=backend
     pod/backend labeled
     ```

   - Set the selector over the previously created label in the service:

     ```console
     > kubectl -n fe-be-test set selector service backend 'name=backend'
     service/backend selector updated
     ```

7. With the solution in place we can see the expected output:

   ```console
   > lynx localhost:8080 -dump
      WordPress
      Select a default language [English (United States)__________]

      Continue
   ```

8. You can then safely remove the namespace:

   ```console
   > kubectl delete namespace fe-be-test
   ```
