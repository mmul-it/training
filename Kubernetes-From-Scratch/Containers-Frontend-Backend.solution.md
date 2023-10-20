# Exercise | Containers Frontend Backend | Solution

1. Create the `172.16.99.0/24` subnet network using `docker network create`:

   ```console
   > docker network create test --subnet "172.16.99.0/24"
   ```

2. Check the [documentation for the container](https://hub.docker.com/_/mariadb/)
   and create the directory that will be used as storage by `mariadb`:

   ```console
   > mkdir backend
   ```

   If you're on Red Hat or CentOS remember to fix the SELinux context of the
   dir:

   ```console
   > chcon -R -t container_file_t backend
   ```

  Run the `mariadb:latest` container:

   ```console
   > docker run --rm --name backend --network=test -v $PWD/backend:/var/lib/mysql \
          -e MYSQL_ROOT_PASSWORD=mybackend \
          -e MYSQL_USER=frontend -e MYSQL_PASSWORD=myfrontend \
          --detach mariadb:latest
   ```

3. Execute a shell on the `mariadb` container to create the `frontend` database
   and set privileges:

   ```console
   > docker exec -it backend mysql -uroot -p
   Enter password:
   Welcome to the MariaDB monitor.  Commands end with ; or \g.
   ...
   ...

   MariaDB [(none)]> CREATE DATABASE frontend;
   Query OK, 1 row affected (0.002s)

   MariaDB [(none)]> GRANT all on frontend.* TO 'frontend'@'172.16.99.%' IDENTIFIED BY 'myfrontend';
   Query OK, 0 rows affected (0.000 sec)

   MariaDB [(none)]> FLUSH PRIVILEGES;
   Query OK, 0 rows affected (0.000 sec)

   MariaDB [(none)]> exit
   Bye
   ```

4. Check the documentation for the [wordpress container](https://hub.docker.com/_/wordpress/)
   and create the `frontend` directory that will be used as `wordpress` storage:

   ```console
   > mkdir frontend
   ```

   If you're on Red Hat or CentOS remember to fix the SELinux context of the
   dir:

   ```console
   > chcon -R -t container_file_t frontend
   ```

   Run the container:

   ```console
   > docker run --rm --name frontend --network=test \
          -e WORDPRESS_DB_HOST=backend \
          -e WORDPRESS_DB_USER=frontend -e WORDPRESS_DB_PASSWORD=myfrontend \
          -e WORDPRESS_DB_NAME=frontend \
          -v $PWD/frontend:/var/www/html --detach -p 8080:80 wordpress:latest
   ```

5. Use a browser to try access to http://localhost:8080 follow video
   instructions to setup Wordpress.

   You can also use a text browser to access the initial wordpress page:

   ```console
   > docker run --rm --network=test -ti fathyb/carbonyl http://frontend
   ```

   This will give you a full (mouse controlled) browser.

6. Stop the containers:

   ```console
   > docker stop backend frontend
   backend
   frontend
   ```

7. Re-run containers with the same parameters as before:

   ```console
   > docker run --rm --name backend --network=test -v $PWD/backend:/var/lib/mysql \
             -e MYSQL_ROOT_PASSWORD=mybackend \
             -e MYSQL_USER=frontend -e MYSQL_PASSWORD=myfrontend \
             --detach mariadb:latest
   2a4769381e2e5c5f12f934eb0ee4157071420a80ce86b55f3257adcde50c9dfc

   > docker run --rm --name frontend --network=test \
            -e WORDPRESS_DB_HOST=backend \
            -e WORDPRESS_DB_USER=frontend -e WORDPRESS_DB_PASSWORD=myfrontend \
            -e WORDPRESS_DB_NAME=frontend \
            -v $PWD/frontend:/var/www/html --detach -p 8080:80 wordpress:latest
   d0897706cec4b245f1c66bd377facd44c031915eea4f397c5f3b804988dcf8ca
   ```

   Check at http://localhost:8080 that everything is fine;

8. Cleanup:

   ```console
   > docker stop backend frontend
   backend
   frontend

   > docker network remove test
   test
   ```