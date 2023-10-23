# Lab | Install GitLab on a container and configure a runner

1. Launch the GitLab instance using the `gitlab/gitlab-ce:latest` container,
   exposing these ports (Host/Container):

   - 8080:80
   - 8443:443
   - 2222:22

   ```console
   > docker run --detach \
     --name gitlab \
     --publish 8080:80 \
     --publish 8443:443 \
     --publish 2222:22 \
     gitlab/gitlab-ce:latest
   ```

   Check the progresses, until the web interface comes up:

   ```console
   > docker logs -f gitlab
   Thank you for using GitLab Docker Image!
   Current version: gitlab-ce=16.0.5-ce.0
   ...
   ```

2. Get the root user password:

   ```console
   > docker exec gitlab cat /etc/gitlab/initial_root_password
   # WARNING: This value is valid only in the following conditions
   #          1. If provided manually (either via `GITLAB_ROOT_PASSWORD` environment variable or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`, it was provided before database was seeded for the first time (usually, the first reconfigure run).
   #          2. Password hasn't been changed manually, either via UI or via command line.
   #
   #          If the password shown here doesn't work, you must reset the admin password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

   Password: nGd+wEG+fIaw+reKUun3YbqrMXYK0JdDMEwE9SwOu1U=

   # NOTE: This file will be automatically deleted in the first reconfigure run after 24 hours.
   ```

   Login into interface and create a user:

   [http://172.16.99.1:8080/admin/users/new](http://172.16.99.1:8080/admin/users/new)

   By giving these inputs:

   - Name: DevSecOps
   - Username: devsecops
   - Email: devsecops@example.com

   And press "Create user".

   Create an SSH keypair:

   ```console
   > ssh-keygen
   > cat ~/.ssh/id_rsa.pub
   ```

   And then add the key by Impersonating the newly created user:

   [http://172.16.99.1:8080/admin/users/devsecops/impersonate](http://172.16.99.1:8080/admin/users/devsecops/impersonate)

   And by adding the `id_rsa.pub` contents as a key for the user:

   [http://172.16.99.1:8080/-/profile/keys](http://172.16.99.1:8080/-/profile/keys)

   Move out from impersonation by click on the `Stop impersonation` icon on the
   top right container.

3. Test the credentials:

   ```console
   > ssh -p 2222 git@172.16.99.1
   The authenticity of host '[172.16.99.1]:2222 ([172.16.99.1]:2222)' can't be established.
   ECDSA key fingerprint is SHA256:cUOv255bj/4Jj5UFUXTItk53CA+/85YnQoKaD1bAjHo.
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added '[172.16.99.1]:2222' (ECDSA) to the list of known hosts.
   PTY allocation request failed on channel 0
   Welcome to GitLab, @devsecops!
   Connection to 172.16.99.1 closed.
   ```

   Create a project with an initial push:

   ```console
   > git config --global user.email "devsecops@example.com"

   > git config --global user.name "devsecops"

   > git config --global init.defaultBranch main

   > mkdir myproject

   > cd myproject

   > git init

   > echo 'My DevSecOps repo' > README.md

   > git add . && git commit -m "Initial commit"

   > git remote add origin ssh://git@172.16.99.1:2222/devsecops/myproject.git

   > git push -u origin main
   Enumerating objects: 3, done.
   Counting objects: 100% (3/3), done.
   Writing objects: 100% (3/3), 232 bytes | 232.00 KiB/s, done.
   Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
   remote:
   remote:
   remote: The private project devsecops/myproject was successfully created.
   remote:
   remote: To configure the remote, run:
   remote:   git remote add origin git@7aa34d0e6b80:devsecops/myproject.git
   remote:
   remote: To view the project, visit:
   remote:   http://7aa34d0e6b80/devsecops/myproject
   remote:
   remote:
   remote:
   To ssh://172.16.99.1:2222/devsecops/myproject.git
    * [new branch]                main -> main
   Branch 'main' set up to track remote branch 'main' from 'origin'.
   ```

4. Fix the IP address of the GitLab Git clone url.

   Using the web interface, as `Administrator` user, change the `Custom Git clone
   URL for HTTP(S)` value in the `Visibility and access controls` section at:

   [http://172.16.99.1:8080/admin/application_settings/general](http://172.16.99.1:8080/admin/application_settings/general)

   Adding the GitLab IP related url, in this case `http://172.16.99.1:8080`
   check [DevSecOps-Pipeline-Requirements.md](DevSecOps-Pipeline-Requirements.md)
   to find out how to get the IP host.

5. Get the GitLab runner token registration at:

   [http://172.16.99.1:8080/devsecops/myproject/-/settings/ci_cd](http://172.16.99.1:8080/devsecops/myproject/-/settings/ci_cd)

   Expanding the "Runners" section and selecting the three dots beside `New
   project runner` and finally copying the token, which will be something like
   `GR1348941uHeDhAB5DDA8r_5xvxsm`.

6. Set up the runner by launching its container:

   ```console
   > mkdir gitlab-runner

   > docker run --detach \
     --name gitlab-runner \
     --privileged \
     --volume /var/run/docker.sock:/var/run/docker.sock \
     --volume $PWD/gitlab-runner:/etc/gitlab-runner \
     gitlab/gitlab-runner:latest
   ```

   Register the runner inside GitLab (note the `--url` option pointing to the
   docker host IP):

   ```console
   > docker exec -it gitlab-runner gitlab-runner register -n \
     --url http://172.16.99.1:8080 \
     --registration-token GR1348941uHeDhAB5DDA8r_5xvxsm \
     --executor docker \
     --description "My Docker Runner" \
     --docker-image "docker:latest" \
     --docker-privileged \
     --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
     --docker-volumes "/certs/client"
   Runtime platform                                    arch=amd64 os=linux pid=54 revision=85586bd1 version=16.0.2
   Running in system-mode.

   WARNING: Support for registration tokens and runner parameters in the 'register' command has been deprecated in GitLab Runner 15.6 and will be replaced with support for authentication tokens. For more information, see https://gitlab.com/gitlab-org/gitlab/-/issues/380872
   Registering runner... succeeded                     runner=GR1348941uHeDhAB5
   Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!

   Configuration (with the authentication token) was saved in "/etc/gitlab-runner/config.toml"
   ```
