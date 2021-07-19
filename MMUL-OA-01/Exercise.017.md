# Exercise 017 - Deploy an application with Helm

---

1. Install Helm (chose the preferred installation method looking at
    https://helm.sh/docs/intro/install/);

2. Create a project named jenkins;

3. Login as kubeadmin to crc;

4. Do ```oc adm policy add-scc-to-user anyuid -z default -n jenkins```;

5. Add Bitnami Helm Repo;

6. Install Jenkins into the namespace jenkins;

7. Check if Jenkins pod is running;
