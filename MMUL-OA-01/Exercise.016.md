# Exercise 016 - Create an ImageStream, deploy and expose an application

---

1. Login as developer, create a new project named 'test-image-streams', and
   check if there are an ImageStream and an Image for
   nginxinc/nginx-unprivileged:stable;

2. Become kubeadmin, write the yaml file and create a new ImageStream named
   'webserver' and tagget as 'latest', that point to the 'nginxinc/nginx-unprivileged:stable'
   docker image. Check if the image is now available in the cluster;

3. Become developer and check if the ImageStream is now available;

4. Deploy and expose a new application from the ImageStream. Test if it
   provides the expected result;
