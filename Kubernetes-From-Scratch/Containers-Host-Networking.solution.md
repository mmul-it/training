# Exercise | Containers Host Networking | Solution

1. Log into minikube and launch the container with `--network host` option:

   ``` console
   > minikube ssh
   
   docker@minikube:~$ docker run -d --name network-host-test --rm --network host nginx
   5ef2cfd4d6aff9d675a299ef9100d0e00e79383dae8cccac4f144e003673b457
   ```

2. Use `curl` to check the port:

   ``` console
   docker@minikube:~$ curl -s http://localhost | grep Welcome
   <title>Welcome to nginx!</title>
   <h1>Welcome to nginx!</h1>
   ```

3. Stop the container:

   ``` console
   docker@minikube:~$ docker stop network-host-test
   network-host-test
   ```

4. Use both `--network host` and `-p 8888:80` to check whether it is possible to publish the port:

   ``` console
   docker@minikube:~$ docker run -d --name network-host-test --rm --network host -p 8888:80 nginx 
   WARNING: Published ports are discarded when using host network mode
   e5c600cf3eab15ef23cb6b79870d7bba8ac4a2fabda7ae7e2a8ba24fbddd5925
   ```

5. Since the result is:
   
   ``` console
   WARNING: Published ports are discarded when using host network mode
   bb499f166a75865d0617c322e78f90724e857b1f404976a3c4a19f946347ba03
   ```
   
   the publication of ports while using the host mode is impossible, there's a WARNING and is just ignored.
