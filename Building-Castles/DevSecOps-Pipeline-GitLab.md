# Lab | Install GitLab on a container and configure a runner

In this lab you will install GitLab and configure its runner to play with CI.

## Launch GitLab

Prepare the environment by creating the dedicated folders with the auto
generated certificate for the `172.16.99.1` IP:

```console
$ export GITLAB_HOME=$PWD/gitlab
(no output)

$ mkdir -v -p gitlab/config/ssl
mkdir: created directory 'gitlab'
mkdir: created directory 'gitlab/config'
mkdir: created directory 'gitlab/config/ssl'

$ export GITLAB_IP='172.16.99.1'
(no output)

$ openssl req -x509 -newkey rsa:4096 -days 365 -nodes \
  -keyout gitlab/config/ssl/$GITLAB_IP.key \
  -out gitlab/config/ssl/$GITLAB_IP.crt \
  -subj "/CN=$GITLAB_IP" -addext "subjectAltName=IP:$GITLAB_IP"
...
```

Launch the GitLab instance using the `gitlab/gitlab-ce` container, exposing
these ports (Host/Container):

- 8443:8443 -> the `https` GitLab port (with an auto generated
  self-signed certificate).
- 2222:22 -> the `ssh` port for git actions.

```console
$ export GITLAB_VERSION=18.4.1-ce.0
(no output)

$ docker run \
  --detach \
  --name gitlab \
  --publish 172.16.99.1:8443:443 \
  --publish 172.16.99.1:2222:22 \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'https://172.16.99.1'; letsencrypt['enable'] = false;" \
  --shm-size=2gb \
  gitlab/gitlab-ce:$GITLAB_VERSION
c516617dfd414f166117ebca02971e8a4ef63676789ad54d1612232dce45d6e1
```

Check the progresses, until the web interface comes up:

```console
$ docker logs -f gitlab
Thank you for using GitLab Docker Image!
Current version: gitlab-ce=18.4.1-ce.0
...
```

## Configure GitLab

Get the root user password:

```console
$ docker exec gitlab cat /etc/gitlab/initial_root_password
# WARNING: This value is valid only in the following conditions
#          1. If provided manually (either via `GITLAB_ROOT_PASSWORD` environment variable or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`, it was provided before database was seeded for the first time (usually, the first reconfigure run).
#          2. Password hasn't been changed manually, either via UI or via command line.
#
#          If the password shown here doesn't work, you must reset the admin password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

Password: nGd+wEG+fIaw+reKUun3YbqrMXYK0JdDMEwE9SwOu1U=

# NOTE: This file will be automatically deleted in the first reconfigure run after 24 hours.
```

Login into interface and create a user:

[https://172.16.99.1:8443/admin/users/new](https://172.16.99.1:8443/admin/users/new)

By giving these inputs:

- Name: DevSecOps
- Username: devsecops
- Email: devsecops@example.com

And press "Create user".

Create an SSH keypair:

```console
$ ssh-keygen
...

$ cat ~/.ssh/id_rsa.pub
...
```

And then add the key by Impersonating the newly created user (click on
`Impersonate`):

[https://172.16.99.1:8443/admin/users/devsecops/](https://172.16.99.1:8443/admin/users/devsecops/)

And by adding the `id_rsa.pub` contents as a key for the user:

[https://172.16.99.1:8443/-/user_settings/ssh_keys](https://172.16.99.1:8443/-/user_settings/ssh_keys)

Move out from impersonation by click on the `Stop impersonation` icon on the
top right container.

## Test GitLab

Test the credentials:

```console
$ ssh -p 2222 git@172.16.99.1
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
$ mkdir -v myproject && cd myproject
mkdir: created directory 'myproject'

$ git init --initial-branch=main
Initialized empty Git repository in /home/kirater/myproject/.git/

$ git config user.email "devsecops@example.com"
(no output)

$ git config user.name "devsecops"
(no output)

$ echo 'My DevSecOps repo' > README.md
(no output)

$ git add . && git commit -m "Initial commit"
 1 file changed, 1 insertion(+)
 create mode 100644 README.md

$ git remote add origin ssh://git@172.16.99.1:2222/devsecops/myproject.git
(no output)

$ git push -u origin main
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

## Get token for GitLab runner

Get the GitLab runner token registration at:

[https://172.16.99.1:8443/devsecops/myproject/-/settings/ci_cd](https://172.16.99.1:8443/devsecops/myproject/-/settings/ci_cd)

Expanding the "Runners" section and selecting the three dots beside `New
project runner` and finally copying the token, which will be something like
`GR1348941uHeDhAB5DDA8r_5xvxsm`.

## Launch GitLab runner

Set up the runner by launching its container:

```console
$ cd && mkdir -v gitlab-runner
mkdir: created directory 'gitlab-runner'

$ export GITLAB_RUNNER_VERSION=v18.4.0
(no output)

$ docker run --detach \
  --name gitlab-runner \
  --privileged \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume $PWD/gitlab-runner:/etc/gitlab-runner \
  --volume $PWD/config/ssl:/etc/gitlab-runner/certs \
  gitlab/gitlab-runner:$GITLAB_RUNNER_VERSION
...
```

Register the runner inside GitLab (note the `--url` option pointing to the
docker host IP):

```console
$ docker exec --interactive --tty gitlab-runner gitlab-runner register -n \
  --url https://172.16.99.1:8443 \
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
