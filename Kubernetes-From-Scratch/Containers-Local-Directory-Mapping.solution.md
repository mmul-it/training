# Exercise | Containers Local Directory Mapping | Solution

1. Create a local directory:

   ```console
   > minikube ssh

   docker@minikube:~$ mkdir local-dir
   ```

   Do not forget to assign the correct SELinux context on the directory, if you
   are on a CentOS/Red Hat system:

   ```console
   > chcon -R -t container_file_t local-dir
   ```

2. Launch the container mapping the directory with `--volume`:

   ```console
   docker@minikube:~$ docker run -d --name local-dir-mapping-test --rm --publish 8080:80 --volume $PWD/local-dir:/usr/share/nginx/html nginx
   5d06d232e6e134d7713265221b81eed4ba7e91a848113286d9400d5164252f64
   ```

3. Nothing. It is still empty, and it's a different behavior from volume. In fact:

   ```console
   docker@minikube:~$ curl localhost:8080
   <html>
   <head><title>403 Forbidden</title></head>
   <body>
   <center><h1>403 Forbidden</h1></center>
   <hr><center>nginx/1.23.2</center>
   </body>
   </html>
   ```

4. Create a file named `index.html` inside the `local-dir` and check via again curl:

   ```console
   docker@minikube:~$ echo "Local dir test" > local-dir/index.html
   docker@minikube:~$ curl localhost:8080
   Local dir test
   ```

5. Stop the container:

   ```console
   docker@minikube:~$ docker stop local-dir-mapping-test
   local-dir-mapping-test
   ```

6. Relaunch the container and check again via curl to confirm persistency:

   ```console
   docker@minikube:~$ docker run -d --name local-dir-mapping-test-relaunch --rm --publish 8080:80 --volume $PWD/local-dir:/usr/share/nginx/html nginx
   a81076af88c696c9b1dd4c763feea90fc1eda9c76a262a56daf7bcfd2b5390ca

   docker@minikube:~$ curl localhost:8080
   Local dir test
   ```
