# Exercise | Containers Same Network

1. In two different shells, create two interactive containers named
   "container1" and "container2" from the image alpine:latest.

2. From "container1" try to ping "container2" and see if it works.

3. Stop and remove the containers.

4. Create a custom network named "test" with the subnet "172.16.99.0/24".

5. In two different shells, create two interactive containers named 
   "container1" and "container2" from the image alpine:latest and inside the
   newly created "test" network.

6. From "container1" try to ping "container2" and see if it works.

7. Listen on the 8888 port on "container1" and try to reach it from
   "container2" to check if everything works.

8. Cleanup everything.
