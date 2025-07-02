# Lab | Create a Terraform manifest with variables

In this lab you will:

1. Create a Terraform working directory named `test-vars` with a manifest named
   `variables.tf` that:
   - Will declare a variable named `image_name` that by default will have the
     `nginx:latest` value.
   - Will declare a variable named `host_port` that will have a default
     value of `8080`.
2. Create a manifest named `main.tf` that:
   - Will use the `kreuzwerker/docker` provider to deploy a `docker_container`
     resource.
   - Will assign the previously declared variables as `image` and `external`
     value (under `ports` section).
3. Initialize the working directory, validate, plan and then apply the
   configurations without any variable passed at command line.
4. Test the deployment and destroy it.
5. Apply again the manifests by passing the value `httpd:latest` as `image_name`
   and `9090` as `host_port`.
6. Test the deployment and destroy it.

## Solution

1. A dedicated directory named `test-vars` will be used as working directory:

   ```console
   $ mkdir -v test-vars && cd test-vars
   mkdir: created directory 'test-vars'
   ```

   The first file to be created will be `variables.tf` that will define the
   variables as requested:

   ```hcl
   variable "image_name" {
     description = "Docker image name to deploy"
     default = "nginx:latest"
   }

   variable "host_port" {
     description = "Port on which Docker container listens"
     default = 8080
   }
   ```

2. The second file, named `main.tf` will have these contents:

   ```hcl
   terraform {
     required_providers {
       docker = {
         source = "kreuzwerker/docker"
       }
     }
   }

   resource "docker_container" "webserver" {
     image = var.image_name
     name = "webserver_container"
     ports {
       internal = 80
       external = var.host_port
     }
   }
   ```

3. It is time to initialize the working directory:

   ```console
   $ terraform init
   Initializing the backend...
   Initializing provider plugins...
   - Finding latest version of kreuzwerker/docker...
   - Installing kreuzwerker/docker v3.6.2...
   - Installed kreuzwerker/docker v3.6.2 (self-signed, key ID BD080C4571C6104C)
   Partner and community providers are signed by their developers.
   If you'd like to know more about provider signing, you can read about it here:
   https://www.terraform.io/docs/cli/plugins/signing.html
   Terraform has created a lock file .terraform.lock.hcl to record the provider
   selections it made above. Include this file in your version control repository
   so that Terraform can guarantee to make the same selections by default when
   you run "terraform init" in the future.

   Terraform has been successfully initialized!

   You may now begin working with Terraform. Try running "terraform plan" to see
   any changes that are required for your infrastructure. All Terraform commands
   should now work.

   If you ever set or change modules or backend configuration for Terraform,
   rerun this command to reinitialize your working directory. If you forget, other
   commands will detect it and remind you to do so if necessary.
   ```

   And then proceed with all the steps until the apply:

   ```console
   $ terraform validate
   Success! The configuration is valid.

   $ terraform plan

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # docker_container.webserver will be created
     + resource "docker_container" "webserver" {
   ...
   ...

   Plan: 1 to add, 0 to change, 0 to destroy.

   ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

   Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.

   $ terraform apply -auto-approve

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # docker_container.webserver will be created
     + resource "docker_container" "webserver" {
   ...
   ...

   Plan: 1 to add, 0 to change, 0 to destroy.
   docker_container.webserver: Creating...
   docker_container.webserver: Creation complete after 4s [id=69613e66c903a1c434834c5ed50c7d7bdfd8bf120db4339beaede6c3bdf5af2a]

   Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
   ```

4. Deployment is fine:

   ```console
   $ docker ps
   CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                  NAMES
   69613e66c903   nginx:latest   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8080->80/tcp   webserver_container
   ```

   And can be destroyed:

   ```console
   $ terraform destroy -auto-approve
   docker_container.webserver: Refreshing state... [id=69613e66c903a1c434834c5ed50c7d7bdfd8bf120db4339beaede6c3bdf5af2a]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     - destroy

   Terraform will perform the following actions:

     # docker_container.webserver will be destroyed
     - resource "docker_container" "webserver" {
   ...
   ...
   Plan: 0 to add, 0 to change, 1 to destroy.
   docker_container.webserver: Destroying... [id=69613e66c903a1c434834c5ed50c7d7bdfd8bf120db4339beaede6c3bdf5af2a]
   docker_container.webserver: Destruction complete after 0s

   Destroy complete! Resources: 1 destroyed.
   ```

5. Applying the manifest again by overriding the variables will be possible by
   using the `-var` option multiple times:

   ```console
   $ terraform apply -var 'image_name=httpd:latest' -var 'host_port=9090' -auto-approve

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # docker_container.webserver will be created
     + resource "docker_container" "webserver" {
   ...
   ...
   Plan: 1 to add, 0 to change, 0 to destroy.
   docker_container.webserver: Creating...
   docker_container.webserver: Creation complete after 0s [id=ad0e1b3cb1525eac4779ce8c433e304546359ba1ea7fe457cb5f6aad2b35fed1]

   Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
   ```

6. Let's test if everything is fine:

   ```console
   $ docker ps
   CONTAINER ID   IMAGE          COMMAND              CREATED          STATUS          PORTS                  NAMES
   ad0e1b3cb152   httpd:latest   "httpd-foreground"   53 seconds ago   Up 52 seconds   0.0.0.0:9090->80/tcp   webserver_container

   $ curl localhost:9090
   <html><body><h1>It works!</h1></body></html>
   ```

   And then destroy everything:

   ```console
   $ terraform destroy -auto-approve
   docker_container.webserver: Refreshing state... [id=ad0e1b3cb1525eac4779ce8c433e304546359ba1ea7fe457cb5f6aad2b35fed1]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     - destroy

   Terraform will perform the following actions:

     # docker_container.webserver will be destroyed
     - resource "docker_container" "webserver" {
   ...
   ...
   Plan: 0 to add, 0 to change, 1 to destroy.
   docker_container.webserver: Destroying... [id=ad0e1b3cb1525eac4779ce8c433e304546359ba1ea7fe457cb5f6aad2b35fed1]
   docker_container.webserver: Destruction complete after 0s

   Destroy complete! Resources: 1 destroyed.

   $ docker ps
   CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
   ```
