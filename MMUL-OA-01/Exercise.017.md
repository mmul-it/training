# Exercise 017 - Deploy an application with Helm

---

1. Install Helm (chose the preferred installation method looking at
    https://helm.sh/docs/intro/install/);

2. Create a project named 'jenkins';

3. As kubeadmin add the 'anyuid' security context constraint to the service
   account default in the 'jenkins' namespace;

5. Add Bitnami Helm Repo;

6. Install Jenkins into the namespace jenkins and expose the service;

7. Check if Jenkins pod is running, get login info and log into the web
   interface;
