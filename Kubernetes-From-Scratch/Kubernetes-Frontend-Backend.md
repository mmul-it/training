# Exercise | Kubernetes Frontend Backend

1. Create a namespace named `fe-be-test`.

2. Create a new pod named `backend` based upon the `mariadb:latest` image inside namespace `fe-be-test`, passing these environmental variables:
   - MYSQL_DATABASE: mywpdb
   - MYSQL_USER: mywpuser
   - MYSQL_PASSWORD: mywppass
   - MYSQL_RANDOM_ROOT_PASSWORD: '1'

3. Create a new pod named `frontend` based upon the `wordpress:latest` image inside namespace `fe-be-test`, passing these environmental variables:
   - WORDPRESS_DB_HOST: backend
   - WORDPRESS_DB_USER: mywpuser
   - WORDPRESS_DB_PASSWORD: mywppass
   - WORDPRESS_DB_NAME: mywpdb

4. Install the `lynx` tool to check rendered http pages from command line.

5. Using `kubectl -n fe-be-test port-forward frontend 8080:80` expose locally the port of the frontend and check the status of wordpress with lynx: what is the problem? Why it is not working?

6. Fix the problems by creating a service for the backend, labeling the pod and set the selector for the service.

7. Check that now the web page shows the initial Wordpress configuration page correctly (and so it connects to the DB).

8. Delete `fe-be-test` namespace.
