# Exercise 018 - Scale-up, scale-down and configure autoscaling

---

1. Login as 'developer' and create the new 'testscale' project;

2. Deploy a new application named scale-docker-app based on the context dir
   s2i-php-helloworld in the git repository https://github.com/mmul-it/docker;

3. Check the ReplicaSet and see if requirements are met;

4. Scale the application up to 3 replicas. Check changes in the ReplicaSet and
   in the running pods;

5. Scale down the application to 1 replica. Check and see when the operation
   ends;

6. Configure autoscaling on this application with a minumum of 1 pod, a
   maximum of 3 pods based on a CPU load of 50%. Then check if everything
   changed as expected;
