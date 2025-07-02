# Lab | Create a simple Terraform manifest to automate containers creation

In this lab you will:

1. Install `docker` on the host.
2. Download and install the `terraform` binary.
3. Create a Terraform manifest which:
   - Will be based on the `kreuzwerker/docker` provider.
   - Will pull the `nginx` Docker image.
   - Will run a container exposing the 8080 port on the host to the 80 port on
     the container.
4. Initialize, validate, plan and then execute the manifest using `terraform`.
5. Test the container creation and the port availability.
6. Destroy everything.

## Solution

1. To install Docker on the host just follow the instructions on the lab named
   [Containers-Install-Docker.md](https://github.com/mmul-it/training/blob/master/Common/Containers-Install-Docker.md).
2. At time of writing, the latest `terraform` available version is the `1.9.8`,
   so to download and make it available to the host use these commands:

   ```console
   $ TF_VERSION=1.9.8
   (no output)

   $ TF_ARCH=linux_amd64
   (no output)

   $ curl -L -O https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_${TF_ARCH}.zip
     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
   100 25.7M  100 25.7M    0     0  82.5M      0 --:--:-- --:--:-- --:--:-- 82.5M

   $ unzip terraform_${TF_VERSION}_${TF_ARCH}.zip
   ...

   $ sudo mv -v terraform /usr/local/bin/
   renamed 'terraform' -> '/usr/local/bin/terraform'
   ```

   Note that if the `unzip` command is not present on the machine, it can be
   installed for RHEL based systems with `sudo yum -y install unzip` and for
   Debian systems with `sudo apt install -y unzip`.

   Now the `terraform` executable should be available everywhere:

   ```console
   $ terraform --version
   Terraform v1.9.8
   on linux_amd64
   ```

3. Looking at the documentation of the `kreuzwerker/docker` provider there are
   examples and explanations about how the provider functionalities can be
   implemented.

   A dedicated directory. named `first-steps` will be used as working directory:

   ```console
   $ mkdir -v first-steps && cd first-steps
   mkdir: created directory 'first-steps'
   ```

   Four main sections will be created inside the `main.tf` file. The first one,
   related to the `required_providers`, where `kreuzwerker/docker` is defined:

   ```hcl
   terraform {
     required_providers {
       docker = {
         source = "kreuzwerker/docker"
       }
     }
   }
   ```

   The second one is the provider itself:

   ```hcl
   provider "docker" {}
   ```

   The third one is the `docker_image` resource:

   ```hcl
   resource "docker_image" "webserver" {
     name = "nginx:latest"
   }
   ```

   The last one the container itself:

   ```hcl
   resource "docker_container" "webserver" {
     image = docker_image.webserver.name
     name = "webserver_container"
     ports {
       internal = 80
       external = 8080
     }
   }
   ```

   The final look of the `main.tf` file will be:

   ```hcl
   terraform {
     required_providers {
       docker = {
         source = "kreuzwerker/docker"
       }
     }
   }

   provider "docker" {}

   resource "docker_image" "webserver" {
     name = "nginx:latest"
   }

   resource "docker_container" "webserver" {
     image = docker_image.webserver.name
     name = "webserver_container"
     ports {
       internal = 80
       external = 8080
     }
   }
   ```

4. It is time to initialize the working directory:

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
   commands will detect it and remind you to do so if necessary
   ```

   Validate the file:

   ```console
   $ terraform validate
   Success! The configuration is valid.
   ```

   Plan the execution:

   ```console
   $ terraform plan

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # docker_container.webserver will be created
     + resource "docker_container" "webserver" {
   ...
   ...
     # docker_image.webserver will be created
     + resource "docker_image" "webserver" {
   ...
   ...
   Plan: 2 to add, 0 to change, 0 to destroy.

   ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

   Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
   ```

   And finally effectively execute it:

   ```console
   $ terraform apply -auto-approve

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # docker_container.webserver will be created
     + resource "docker_container" "webserver" {
   ...
   ...
     # docker_image.webserver will be created
     + resource "docker_image" "webserver" {
   ...
   ...
   Plan: 2 to add, 0 to change, 0 to destroy.
   docker_image.webserver: Creating...
   docker_image.webserver: Creation complete after 4s [id=sha256:fffffc90d343cbcb01a5032edac86db5998c536cd0a366514121a45c6723765cnginx:latest]
   docker_container.webserver: Creating...
   docker_container.webserver: Creation complete after 0s [id=50d56a4aa6ca8f1bca478be9300367fcd27461afd0a29d0c15dbf5a6df098f47]

   Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
   ```

   Note that with previous versions of the docker provider every time you
   launched the `terraform apply` command, a new container was created, because
   the module didn't record the ID. This could have been be avoided by using
   the `ignore_changes` option inside the resource declaration, as in:

   ```hcl
   resource "docker_container" "webserver" {
     image = docker_image.webserver.name
     name = "webserver_container"
     ports {
       internal = 80
       external = 8080
     }
     lifecycle {
       ignore_changes = all
     }
   }
   ```

5. All the tests can be made from the hosts:

   ```console
   $ docker ps
   CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                  NAMES
   50d56a4aa6ca   nginx:latest   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8080->80/tcp   webserver_container

   $ curl localhost:8080
   <!DOCTYPE html>
   <html>
   <head>
   <title>Welcome to nginx!</title>
   <style>
   html { color-scheme: light dark; }
   body { width: 35em; margin: 0 auto;
   font-family: Tahoma, Verdana, Arial, sans-serif; }
   </style>
   </head>
   <body>
   <h1>Welcome to nginx!</h1>
   <p>If you see this page, the nginx web server is successfully installed and
   working. Further configuration is required.</p>

   <p>For online documentation and support please refer to
   <a href="http://nginx.org/">nginx.org</a>.<br/>
   Commercial support is available at
   <a href="http://nginx.com/">nginx.com</a>.</p>

   <p><em>Thank you for using nginx.</em></p>
   </body>
   </html>
   ```

6. Destroying everything is just a matter of:

   ```console
   $ terraform destroy -auto-approve
   docker_image.webserver: Refreshing state... [id=sha256:fffffc90d343cbcb01a5032edac86db5998c536cd0a366514121a45c6723765cnginx:latest]
   docker_container.webserver: Refreshing state... [id=50d56a4aa6ca8f1bca478be9300367fcd27461afd0a29d0c15dbf5a6df098f47]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     - destroy

   Terraform will perform the following actions:

     # docker_container.webserver will be destroyed
     - resource "docker_container" "webserver" {
   ...
   ...
   Plan: 0 to add, 0 to change, 2 to destroy.
   docker_container.webserver: Destroying... [id=50d56a4aa6ca8f1bca478be9300367fcd27461afd0a29d0c15dbf5a6df098f47]
   docker_container.webserver: Destruction complete after 0s
   docker_image.webserver: Destroying... [id=sha256:fffffc90d343cbcb01a5032edac86db5998c536cd0a366514121a45c6723765cnginx:latest]
   docker_image.webserver: Destruction complete after 0s

   Destroy complete! Resources: 2 destroyed.

   $ docker ps
   CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
   ```
