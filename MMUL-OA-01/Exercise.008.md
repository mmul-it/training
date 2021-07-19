# Exercise 008 - Create a new user in your local OpenShift

---

1. As user 'kubeadmin' check the oauth default configuration for crc;

2. Identify the secret associated with the default authentication;

3. Download the secret to a local file using ```oc extract```;

4. Add a user using 'htpasswd' and push the newly created file to the secret;

5. Check if you can login (you should not) and create the crc user so that
   you'll be able to login properly;
