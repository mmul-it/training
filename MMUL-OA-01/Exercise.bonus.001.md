# Exercise Bonus 001 - Perform updates and rollback of a deployment

---

1. As developer create a new namespace named 'testdeploy'. Then create a new
   deployment named 'webserver' using the 'nginxinc/nginx-unprivileged:1.19-perl'
   image. Check and wait until the deployment completes;

2. Create a service to expose the port 8080 of the pod, then create a route to
   access that outside the OCP cluster. Access an unavailable page to see the
   webserver version;

3. Update the deployment changing the container image with the one tagged
   '1.20-perl'. Follow the rollout progress then check if the webserver report
   the correct version;

4. Update again the deployment with the image tagged '1.21-perl'. Again, check
   the running version;

5. Look at the rollout history and rollback the deployment its first iteration.
