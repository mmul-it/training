# Exercise | Containers Environment Variables | Solution

1. Run the container after logging into minikube via ssh:

   ```console
   > minikube ssh

   docker@minikube:~$ docker run -d -e MESSAGE="Test content" --name environment-var-test nginx
   7c1f15079d3ca1e851af947d8cb673cfb80177421da21be3da3c35ab2c4609d6
   ```

2. Use a shell to log into the container and check the content of the variable:

   ```console
   docker@minikube:~$ docker exec -it  environment-var-test /bin/bash
   root@7c1f15079d3c:/# echo $MESSAGE
   Test content

   root@7c1f15079d3c:/# exit
   exit
   docker@minikube:~$
   ```

3. Use another shell, overriding the content of the variable:

   ```console
   docker@minikube:~$ docker exec -it -e MESSAGE="Modified test content" environment-var-test /bin/bash
   root@d1a23db58736:/# echo $MESSAGE
   Modified test content

   root@7c1f15079d3c:/# exit
   exit
   docker@minikube:~$
   ```

4. Check another last time the status of the variable with no override:

   ```console
   docker@minikube:~$ docker exec -it environment-var-test /bin/bash
   root@7c1f15079d3c:/# echo $MESSAGE
   Test content

   root@7c1f15079d3c:/# exit
   exit
   docker@minikube:~$
   ```

5. No, the value is still the original. This means that the override produced by
   the exec counts just from there on, it is not retroactive. Which means that
   the only way to reset the environment variable is to stop and start the
   container once again with a new -e option specified.
