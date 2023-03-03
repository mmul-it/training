# Exercise | Kubernetes Scale And Autoscale

1. Create a namespace named `scale-test`.

2. Deploy an `nginx` deployment inside the `scale-test` namespace.

3. Check the ReplicaSet and see if requirements are met;

4. Scale the application up to 3 replicas. Check changes in the ReplicaSet and in the running pods.

5. Scale down the application to 1 replica. Check and see when the operation ends.

6. Configure autoscaling on this application with a minumum of 1 pod, a maximum of 3 pods based on a CPU load of 50%. Then check if everything changed as expected.

7. Install the `stress` command inside the `nginx` pod and launch it with `stress --cpu 3` to increase the CPU load. Then check if pod replicas are increased by hpa.

8. Stop `stress` command and check that the replicas come back to 1.
