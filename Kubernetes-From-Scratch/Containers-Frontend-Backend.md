# Exercise | Containers Frontend Backend

1. Create a custom network named `test` with the subnet `172.16.99.0/24`.

2. Create a backend container named `backend` that will:
   - Rely on the `test` network.
   - Map `/var/lib/mysql` data directory into the local one named `backend`.
   - Use `mybackend` as the root password.
   - Create a user named `frontend` with password `myfrontend`.
   - Based upon the `mariadb:latest` container image.
   - Be removed once stopped.

3. Grant all the permission to the user `frontend` on the database `frontend`.

4. Create a frontend container named `frontend` that will:
   - Rely on the `test` network.
   - Map `/var/www/html` data directory into the local one named `frontend`.
   - Connect to the database using the previously created user `frontend`
     credentials.
   - Map the `80` port of the container locally.
   - Based upon the `wordpress:latest` container image.
   - Be removed once stopped.

5. Connect to `http://localhost:8080` and make some customizations to the
   wordpress instance.

6. Stop both containers.

7. Start them again with the same commands and check if customizations were
   kept.

8. Cleanup everything.
