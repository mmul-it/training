# Lab | Containers Frontend Backend

In this lab you will:

1. Create a custom network named `test` with the subnet `172.16.99.0/24`.
2. Create a backend container named `backend` that will:
   - Rely on the `test` network.
   - Map `/var/lib/mysql` data directory into the local one named `backend`.
   - Use `mybackend` as the root password.
   - Create a user named `frontend` with password `myfrontend`.
   - Based upon the `mariadb:latest` container image.
   - Be removed once stopped.
3. Create a frontend container named `frontend` that will:
   - Rely on the `test` network.
   - Map `/var/www/html` data directory into the local one named `frontend`.
   - Connect to the database using the previously created user `frontend`
     credentials.
   - Map the `80` port of the container locally.
   - Based upon the `wordpress:latest` container image.
   - Be removed once stopped.
4. Connect to `http://localhost:8080` and make some customizations to the
   wordpress instance.
5. Stop both containers.
6. Start them again with the same commands and check if customizations were
   kept.
7. Cleanup everything.

## Solution

1. Create the `172.16.99.0/24` subnet network using `docker network create`:

   ```console
   $ docker network create test --subnet "172.16.99.0/24"
   434587abd6cf606c755ea5af70ac4d67fd31d0e954dc70fec49ee019d3f19e33
   ```

2. Check the [documentation for the container](https://hub.docker.com/_/mariadb/)
   and create the directory that will be used as storage by `mariadb`:

   ```console
   $ mkdir backend
   (no output)
   ```

   If you're on Red Hat or CentOS remember to fix the SELinux context of the
   dir:

   ```console
   $ chcon -R -t container_file_t backend
   (no output)
   ```

   Run the `backend` container using the `mariadb:latest` image:

   ```console
   $ docker run --detach --rm --name backend --network=test \
       --volume $PWD/backend:/var/lib/mysql \
       --env MYSQL_ROOT_PASSWORD=mybackend \
       --env MYSQL_DATABASE=frontend \
       --env MYSQL_USER=frontend \
       --env MYSQL_PASSWORD=myfrontend \
       mariadb:latest
   c0c63d3d6ba0df18a0f876cb3796c9a718b7781b614e94e7c4c49809649540c7
   ```

3. Check the documentation for the [wordpress container](https://hub.docker.com/_/wordpress/)
   and create the `frontend` directory that will be used as `wordpress` storage:

   ```console
   $ mkdir frontend
   (no output)
   ```

   If you're on Red Hat or CentOS remember to fix the SELinux context of the
   dir:

   ```console
   $ chcon -R -t container_file_t frontend
   (no output)
   ```

   Run the container:

   ```console
   $ docker run --detach --rm --name frontend --network=test \
       --env WORDPRESS_DB_HOST=backend \
       --env WORDPRESS_DB_USER=frontend \
       --env WORDPRESS_DB_PASSWORD=myfrontend \
       --env WORDPRESS_DB_NAME=frontend \
       --volume $PWD/frontend:/var/www/html \
       --publish 8080:80 \
       wordpress:latest
   6e2420f3b841bef2784cc2832f1dc8f73b8915c228d24a1933cbbffda749b92a
   ```

4. Use a browser to try access to `http://localhost:8080` follow video
   instructions to setup Wordpress.

   You can also use a text browser to access the initial wordpress page:

   ```console
   $ docker run --rm --network=test -ti fathyb/carbonyl http://frontend
   (a rendered web page should appear)
   ```

   This will give you a full (mouse controlled) browser.

   To exit carbonyl just press `Ctrl+C`.

5. Stop the containers:

   ```console
   $ docker stop backend frontend
   backend
   frontend
   ```

6. Re-run containers. For the `mariadb` container there's no need to pass env
   vars again, since it will take these settings from the persistent folder:

   ```console
   $ docker run --detach --rm --name backend --network=test \
       --volume $PWD/backend:/var/lib/mysql \
       mariadb:latest
   2a4769381e2e5c5f12f934eb0ee4157071420a80ce86b55f3257adcde50c9dfc

   $ docker run --detach --rm --name frontend --network=test \
       --env WORDPRESS_DB_HOST=backend \
       --env WORDPRESS_DB_USER=frontend \
       --env WORDPRESS_DB_PASSWORD=myfrontend \
       --env WORDPRESS_DB_NAME=frontend \
       --volume $PWD/frontend:/var/www/html \
       --publish 8080:80 \
       wordpress:latest
   d0897706cec4b245f1c66bd377facd44c031915eea4f397c5f3b804988dcf8ca
   ```

   Check at `http://localhost:8080` that everything is fine;

7. Cleanup:

   ```console
   $ docker stop backend frontend
   backend
   frontend

   $ docker network remove test
   test
   ```
