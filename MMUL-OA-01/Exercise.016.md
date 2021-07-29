# Exercise 016 - Use ImageStreams to perform updates and rollback of a DeploymentConfig

---

1. As developer create a new project named 'testdeploy';

2. Create an ImageStream named 'webserver', and import as 'webserver:1.19-perl'
   the image coming from ```nginxinc/nginx-unprivileged:1.19-perl``` into it,
   tagging it also 'latest';

3. Create and expose a DeploymentConfig by using ```oc new-app``` command with
   the specific ```--as-deployment-config``` option, naming it 'webserver' and
   getting the image from the image stream 'webserver:latest';

4. Check the automatically created trigger inside the 'webserver'
   DeploymentConfig;

5. Import into the 'webserver' ImageStream the '1.20-perl' image, tagging it as
   'latest', and look if the trigger is executed;

6. Import into the 'webserver' ImageStream the '1.21-perl' image, tagging also
   this new one as 'latest', and look if the trigger is executed;

7. Look at the rollout history and rollback the deployment its first iteration;
