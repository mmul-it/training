# Exercise 009 - Explore current SCC and add more permissions to a deployment

---

1. As admin, look at available SCCs and explore some details (like anyuid,
   privileged and restricted);

2. As developer try deploying a new app inside a new project named 'scc-test'
   based on a container which require root privileges (like nginx:latest
   docker-image);

3. Show logs and see why the pod can't run;

4. Create a new ServiceAccount named 'useroot';

5. As admin use the add-scc-to-user policy to add anyuid scc to useroot service
   account;

6. Then, as developer, edit the 'nginx' deployment to add 'useroot' as
   'serviceAccountName' attribute inside 'spec:template:spec:' attribute;

7. Check the new status of the deployment and look at logs to show if pods are
   running correctly;
