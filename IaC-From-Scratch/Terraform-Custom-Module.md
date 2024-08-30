# Lab | Create a custom Terraform module to deploy a webserver

In this lab you will:

1. Create a Terraform working directory named `custom-module` where the entire
   structure of the `mydocker` module and the relative environments will live.
   As follows:

   ```console
   custom-module
   ├── modules
   │   └── mydocker
   ├── production
   └── staging
   ```

2. Inside the `modules/mydocker` create three files:
   - `main.tf`: that will use the `kreuzwerker/docker` provider to create a
     `docker_container` resource named `webserever` with a `name`, `image` and
     `ports` all coming from variables.
   - `variables.tf`: that will define four variables:
     - `image_name`, string.
     - `container_name`, string.
     - `container_port`, number.
     - `host_port`, number.
   - `outputs.tf`: that will return the `docker_container.webserver.id` value.
3. Create a `main.tf` file inside `staging` with the `module` section calling
   the `mydocker` module with these vars:
   - `image_name` = `nginx:latest`
   - `container_name` = `my-nginx-container`
   - `container_port` = `80'
   - `host_port` = `8080`
   and printing the output named `container_id_from_module` coming from
   `module.mydocker.container_id`.
4. Create a `main.tf` file inside `production` with the `module` section calling
   the `mydocker` module with these vars:
   - `image_name` = `httpd:latest`
   - `container_name` = `my-httpd-container`
   - `container_port` = `80'
   - `host_port` = `9090`
   and printing the output named `container_id_from_module` coming from
   `module.mydocker.container_id`.
5. Initialize and apply `staging` and `production` environments.
6. Verify the deployments and destroy everything.

## Solution

1. The dedicated directory with subdirectories can be created in one single
   command:

   ```console
   $ cd $HOME && mkdir -vp custom-module/{modules/mydocker,production,staging} && cd custom-module
   mkdir: created directory 'custom-module'
   mkdir: created directory 'custom-module/modules'
   mkdir: created directory 'custom-module/modules/mydocker'
   mkdir: created directory 'custom-module/production'
   mkdir: created directory 'custom-module/staging'
   ```

2. The contents of the `modules/mydocker/main.tf` file will be like these:

   ```hcl
   terraform {
     required_providers {
       docker = {
         source = "kreuzwerker/docker"
         version = "3.0.2"
       }
     }
   }

   resource "docker_container" "webserver" {
     name  = var.container_name
     image = var.image_name

     ports {
       internal = var.container_port
       external = var.host_port
     }
   }
   ```

   Variables will be defined in `modules/mydocker/variables.tf`:

   ```hcl
   variable "image_name" {
     description = "Docker image name"
     type = string
   }

   variable "container_name" {
     description = "Name of the container"
     default     = "example-container"
     type = string
   }

   variable "container_port" {
     description = "Container listen port"
     default     = 80
     type = number
   }

   variable "host_port" {
     description = "Mapped host port"
     default     = 8080
     type = number
   }
   ```

   Finally `modules/mydocker/outputs.tf` will contain:

   ```console
   output "container_id" {
     value = docker_container.webserver.id
   }
   ```

3. To call the module under staging the contents of `staging/main.tf` will be:

   ```hcl
   module "mydocker" {
     source      = "../modules/mydocker"
     image_name  = "nginx:latest"
     container_name = "my-nginx-container"
     container_port = 80
     host_port   = 8080
   }

   output "container_id_from_module" {
     description = "The ID of the container created by the module"
     value       = module.mydocker.container_id
   }
   ```

4. To call the module under production the contents of `production/main.tf`
   will be:

   ```hcl
   module "mydocker" {
     source      = "../modules/mydocker"
     image_name  = "httpd:latest"
     container_name = "my-httpd-container"
     container_port = 80
     host_port   = 9090
   }

   output "container_id_from_module" {
     description = "The ID of the container created by the module"
     value       = module.mydocker.container_id
   }
   ```

5. It is time to initialize the environments and apply the manifests, and
   without moving from the working directory this can be done using `-chdir`
   command line option.

   To initialize `staging`:

   ```console
   $ terraform -chdir=staging init
   Initializing the backend...
   Initializing modules...
   - mydocker in ../modules/mydocker
   Initializing provider plugins...
   - Finding kreuzwerker/docker versions matching "3.0.2"...
   - Installing kreuzwerker/docker v3.0.2...
   - Installed kreuzwerker/docker v3.0.2 (self-signed, key ID BD080C4571C6104C)
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

   To initialize `production`:

   ```console
   $ terraform -chdir=production init
   Initializing the backend...
   Initializing modules...
   - mydocker in ../modules/mydocker
   Initializing provider plugins...
   - Finding kreuzwerker/docker versions matching "3.0.2"...
   - Installing kreuzwerker/docker v3.0.2...
   - Installed kreuzwerker/docker v3.0.2 (self-signed, key ID BD080C4571C6104C)
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

   Then to apply `staging`:

   ```console
   $ terraform -chdir=staging apply -auto-approve

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # module.mydocker.docker_container.webserver will be created
     + resource "docker_container" "webserver" {
   ...
   ...
   Plan: 1 to add, 0 to change, 0 to destroy.

   Changes to Outputs:
     + container_id_from_module = (known after apply)
   module.mydocker.docker_container.webserver: Creating...
   module.mydocker.docker_container.webserver: Creation complete after 0s [id=c88d5b7920605ca43be856a91bcb0cbbbcff8c7d57847d65267a4cf091a4471b]

   Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

   Outputs:

   container_id_from_module = "c88d5b7920605ca43be856a91bcb0cbbbcff8c7d57847d65267a4cf091a4471b"
   ```

   And finally to apply `production`:

   ```console
   $ terraform -chdir=production apply -auto-approve

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     + create

   Terraform will perform the following actions:

     # module.mydocker.docker_container.webserver will be created
     + resource "docker_container" "webserver" {
   ...
   ...
   Plan: 1 to add, 0 to change, 0 to destroy.

   Changes to Outputs:
     + container_id_from_module = (known after apply)
   module.mydocker.docker_container.webserver: Creating...
   module.mydocker.docker_container.webserver: Creation complete after 1s [id=3f6ede05abfa7bec14bda9aacde36e77103bb3893569fbbf3d403366dd379734]

   Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

   Outputs:

   container_id_from_module = "3f6ede05abfa7bec14bda9aacde36e77103bb3893569fbbf3d403366dd379734"
   ```

   Notice in both outputs the value of the ids, that will match the `docker ps`
   output.

6. To test everything:

   ```console
   $ docker ps
   CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                  NAMES
   3f6ede05abfa   httpd:latest   "httpd-foreground"       About a minute ago   Up About a minute   0.0.0.0:9090->80/tcp   my-httpd-container
   c88d5b792060   nginx:latest   "/docker-entrypoint.…"   2 minutes ago        Up 2 minutes        0.0.0.0:8080->80/tcp   my-nginx-container

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

   $ curl localhost:9090
   <html><body><h1>It works!</h1></body></html>
   ```

   And the destruction can be as well launched from the working directory, by
   using again `-chdir`:

   ```console
   $ terraform -chdir=staging destroy -auto-approve
   module.mydocker.docker_container.webserver: Refreshing state... [id=c88d5b7920605ca43be856a91bcb0cbbbcff8c7d57847d65267a4cf091a4471b]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     - destroy

   Terraform will perform the following actions:

     # module.mydocker.docker_container.webserver will be destroyed
     - resource "docker_container" "webserver" {
   ...
   ...

   Plan: 0 to add, 0 to change, 1 to destroy.

   Changes to Outputs:
     - container_id_from_module = "c88d5b7920605ca43be856a91bcb0cbbbcff8c7d57847d65267a4cf091a4471b" -> null
   module.mydocker.docker_container.webserver: Destroying... [id=c88d5b7920605ca43be856a91bcb0cbbbcff8c7d57847d65267a4cf091a4471b]
   module.mydocker.docker_container.webserver: Destruction complete after 0s

   Destroy complete! Resources: 1 destroyed.

   $ terraform -chdir=production destroy -auto-approve
   module.mydocker.docker_container.webserver: Refreshing state... [id=3f6ede05abfa7bec14bda9aacde36e77103bb3893569fbbf3d403366dd379734]

   Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
     - destroy

   Terraform will perform the following actions:

     # module.mydocker.docker_container.webserver will be destroyed
     - resource "docker_container" "webserver" {
   ...
   ...

   Plan: 0 to add, 0 to change, 1 to destroy.

   Changes to Outputs:
     - container_id_from_module = "3f6ede05abfa7bec14bda9aacde36e77103bb3893569fbbf3d403366dd379734" -> null
   module.mydocker.docker_container.webserver: Destroying... [id=3f6ede05abfa7bec14bda9aacde36e77103bb3893569fbbf3d403366dd379734]
   module.mydocker.docker_container.webserver: Destruction complete after 0s

   Destroy complete! Resources: 1 destroyed.

   $ docker ps
   CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
   ```
