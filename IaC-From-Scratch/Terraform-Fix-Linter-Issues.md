# Lab | Use a linter to increase code quality

In this lab you will:

1. Use the `variables.tf` and `main.tf` manifests created in the
   [Terraform-Manifest-With-Vars.md](Terraform-Manifest-With-Vars.md) lab.
2. Install `tflint` and make it available in the host.
3. Launch `tflint` and check which warnings are produced.
4. Fix the warnings following the suggestions and verify with `tflint` that the
   manifest is now OK.

## Solution

1. Lab will contain inside the `test-vars` directory one file named
   `variables.tf` with these contents:

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

   And one name `main.tf` with these contents:

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

2. The `tflint` binary installation works exactly as the `terraform` one. First
   the zip archive should be downloaded from the realease on the GitHub repo:

   ```console
   $ curl -L -O https://github.com/terraform-linters/tflint/releases/download/v0.52.0/tflint_linux_amd64.zip
   ...
   ```

   Then the file must be unzipped and copied into the `/usr/local/bin/` path:

   ```console
   $ unzip tflint_linux_amd64.zip
   ...

   $ sudo mv -v tflint /usr/local/bin
   renamed 'tflint' -> '/usr/local/bin/tflint'
   ```

   And now the binary is available to the host:

   ```console
   $ tflint --version
   TFLint version 0.52.0
   + ruleset.terraform (0.8.0-bundled)
   ```

3. To start the analysis `tflint` should be launched with the `--chdir`
   parameter pointing to the manifests' directory:

   ```console
   $ tflint --chdir=test-vars
   4 issue(s) found:

   Warning: terraform "required_version" attribute is required (terraform_required_version)

     on test-vars/main.tf line 1:
      1: terraform {

   Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.8.0/docs/rules/terraform_required_version.md

   Warning: Missing version constraint for provider "docker" in `required_providers` (terraform_required_providers)

     on test-vars/main.tf line 3:
      3:     docker = {
      4:       source = "kreuzwerker/docker"
      5:     }

   Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.8.0/docs/rules/terraform_required_providers.md

   Warning: `image_name` variable has no type (terraform_typed_variables)

     on test-vars/variables.tf line 1:
      1: variable "image_name" {

   Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.8.0/docs/rules/terraform_typed_variables.md

   Warning: `host_port` variable has no type (terraform_typed_variables)

     on test-vars/variables.tf line 6:
      6: variable "host_port" {

   Reference: https://github.com/terraform-linters/tflint-ruleset-terraform/blob/v0.8.0/docs/rules/terraform_typed_variables.md
   ```

   There are 4 issues, in total, very detailed about where the problem is.

4. The first issue is about missing `required_version` in `main.tf`. In fact, a
   best practice is to set the Terraform version that was used to test the
   manifests.

   To fix this, set the `required_version` to `1.9.8`, the Terraform version
   used while deploying and testing these manifests:

   ```hcl
   terraform {
     required_version = "1.9.8"
   ```

   The second warning is about the Docker provider version missing, still in
   `main.tf` which should always match the one used to deploy the manifests, in
   this case `3.0.2`:

   ```hcl
     required_providers {
       docker = {
         source  = "kreuzwerker/docker"
         version = "3.0.2"
       }
     }
   }
   ```

   The last two warnings are similar, because they are both referring to the
   missing variable type in `variables.tf`, that will be `string` for
   `image_name` and `number` for `host_port`:

   ```hcl
   variable "image_name" {
     description = "Docker image name to deploy"
     default = "nginx:latest"
     type = string
   }

   variable "host_port" {
     description = "Port on which Docker container listens"
     default = 8080
     type = number
   }
   ```

   It is time to check if these modifications are now satisfying the linter:

   ```console
   $ tflint --chdir=test-vars
   (no output)

   $ echo $?
   0
   ```

   No output, and a zero return code for the command are confirming that now
   files are correctly respecting the linter.
