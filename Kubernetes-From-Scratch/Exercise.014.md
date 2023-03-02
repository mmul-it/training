# Exercise 014 - Attach a PVC to a deployment

1. Run inside the `volumes-test` namespace (created in [Exercise 013](Exercise.013.solutions.md)) an `nginx` pod.

2. Mount the PVC named `myclaim` (created in [Exercise 013](Exercise.013.solutions.md)) in the `/usr/share/nginx/html` directory.

3. From the minikube host create an `index.html` file inside `/usr/share/nginx/html` displaying `THIS COMES FROM MY VOLUME`.

4. Check if the message is correctly displayed.

5. Delete the `volumes-test` namespace and check the status of the persistent volume.
