# Exercise 019 - Create a custom template

---

1. Login as kubeadmin;

2. Starting from nginx-example template, create a yaml file for your new
   simple-nginx template;

3. Customize the simple-nginx.yml template definition by:
   - Replacing all occurrence of "nginx-example" with "simple-nginx"
   - Create a new parameter named REPLICAS that will manage the number of
     replicas inside the DeploymentConfig specs.

4. Create the template on the cluster;

5. Deploy a new app from this template;
