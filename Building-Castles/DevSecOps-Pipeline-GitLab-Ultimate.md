# Lab | Install GitLab on a container and configure a runner

In this lab you will install GitLab and configure its runner to play with CI.

## Launch GitLab

Launch the GitLab Enterprise instance using the `gitlab/gitlab-ee` container,
exposing these ports (Host/Container):

- 8080:80 -> the `http` GitLab Ultimate UI port.
- 8443:8443 -> the `https` GitLab Ultimate UI port (with an auto generated
  self-signed certificate).
- 2222:22 -> the `ssh` port for git actions.
- 5050:5050 -> the GitLab Ultimate Container Registry service port.

```console
$ GITLAB_VERSION=18.8.2-ee.0
(no output)

$ GITLAB_HOME=$HOME/gitlab \
  docker run \
  --detach \
  --name gitlab \
  --publish 172.16.99.1:8080:80 \
  --publish 172.16.99.1:8443:8443 \
  --publish 172.16.99.1:2222:22 \
  --publish 172.16.99.1:5050:5050 \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'https://172.16.99.1:8443'; registry_external_url 'https://172.16.99.1:5050'" \
  --shm-size=2gb \
  gitlab/gitlab-ee:$GITLAB_VERSION
706346108a7168c07994c411815cfd60ddd65722131c4cfb9ff4ca37b828a26c
```

The meaning of some of the options used to launch the GitLab Ultimate container
will be explained further in the laboratories.

Check the progresses, until the web interface comes up:

```console
$ docker logs -f gitlab
...
```

## Configure GitLab Ultimate

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

Login into interface and, after accepting the self signed certificate, go to the
GitLab Ultimate Subscription page:

[https://172.16.99.1:8443/admin/subscription](https://172.16.99.1:8443/admin/subscription)

Insert the activation code and press `Activate`.

## Configure Users

We will create three users: `AdmDevSecOps`, the project owner, `MntDevSecOps`,
the project maintainer, and `DevSecOps`, the project developer.

### AdmDevSecOps

To create the project owner go to:

[https://172.16.99.1:8443/admin/users/new](https://172.16.99.1:8443/admin/users/new)

Fill with these inputs:

- Name: AdmDevSecOps
- Username: admdevsecops
- Email: admdevsecops@example.com

And press "Create user".

Create an SSH keypair:

```console
$ ssh-keygen -f admdevsecops
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in admdevsecops
Your public key has been saved in admdevsecops.pub
The key fingerprint is:
SHA256:FczZD0aFAehYjGrpkbQIe914x/TtE3YVOFXLTXfbjkb kirater@training-adm
The key's randomart image is:
+---[RSA 3072]----+
|     o ...o+. +==|
|. . . +o.+.  o+o=|
|.+ * * o=.=.. oB.|
|o O + + o+.o+oo  |
| + . . .S  oEo   |
|  .         o    |
|             .   |
|                 |
|                 |
+----[SHA256]-----+
...

$ cat admdevsecops.pub
...
```

And then add the key by Impersonating the newly created user. Go to:

[https://172.16.99.1:8443/admin/users/admdevsecops/](https://172.16.99.1:8443/admin/users/admdevsecops/)

Click `Impersonate`.

Add the `admdevsecops.pub` contents as a key for the user:

[https://172.16.99.1:8443/-/user_settings/ssh_keys](https://172.16.99.1:8443/-/user_settings/ssh_keys)

Move out from impersonation by click on the `Stop impersonation` icon on the
top right corner.

### MntDevSecOps

To create the maintainer user go to:

[https://172.16.99.1:8443/admin/users/new](https://172.16.99.1:8443/admin/users/new)

Fill with these inputs:

- Name: MntDevSecOps
- Username: mntdevsecops
- Email: mntdevsecops@example.com

And press "Create user".

Create an SSH keypair:

```console
$ ssh-keygen -f mntdevsecops
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in mntdevsecops
Your public key has been saved in mntdevsecops.pub
The key fingerprint is:
SHA256:JczZD0aFAehYjGrpkbQIe914x/TtE3YVOFXLTXgasbI kirater@training-adm
The key's randomart image is:
+---[RSA 3072]----+
|     o ...o+. +==|
|. . . +o.+.  o+o=|
|.+ * * o=.=.. oB.|
|o O + + o+.o+oo  |
| + . . .S  oEo   |
|  .         o    |
|             .   |
|                 |
|                 |
+----[SHA256]-----+
...

$ cat mntdevsecops.pub
...
```

And then add the key by Impersonating the newly created user:

[https://172.16.99.1:8443/admin/users/mntdevsecops/](https://172.16.99.1:8443/admin/users/mntdevsecops/)

And by adding the `mntdevsecops.pub` contents as a key for the user:

[https://172.16.99.1:8443/-/user_settings/ssh_keys](https://172.16.99.1:8443/-/user_settings/ssh_keys)

Move out from impersonation by click on the `Stop impersonation` icon on the
top right corner.

### DevSecOps

To create the `devsecops` user, which will be our developer, use the same link
as before:

[https://172.16.99.1:8443/admin/users/new](https://172.16.99.1:8443/admin/users/new)

This time give these inputs:

- Name: DevSecOps
- Username: devsecops
- Email: devsecops@example.com

And press "Create user".

Create the default SSH keypair:

```console
$ ssh-keygen
...

$ cat ~/.ssh/id_rsa.pub
...
```

And then add the key by Impersonating the newly created user:

[https://172.16.99.1:8443/admin/users/devsecops/](https://172.16.99.1:8443/admin/users/devsecops/)

And by adding the `id_rsa.pub` contents as a key for the user:

[https://172.16.99.1:8443/-/user_settings/ssh_keys](https://172.16.99.1:8443/-/user_settings/ssh_keys)

Move out from impersonation by click on the `Stop impersonation` icon on the
top right container.

## Create building-castles group

Create a group named `building-castles` where the test repository will live:

[https://172.16.99.1:8443/groups/new#create-group-pane](https://172.16.99.1:8443/groups/new#create-group-pane)

Fill just:

- Group name: building-castles

And then press `Create group`.

After this add `AdmDevSecOps` to the group, go to:

[https://172.16.99.1:8443/groups/building-castles/-/group_members](https://172.16.99.1:8443/groups/building-castles/-/group_members)

And press `Invite members`, and put `AdmDevSecOps` as `Owner` role for the
group. This will make us able to use this user to create security policies.

## Create myproject project

Create a project where all the tests will be made:

[https://172.16.99.1:8443/projects/new#blank_project](https://172.16.99.1:8443/projects/new#blank_project)

By passing just:

- Project name: myproject

And ensuring group is `building-castles` then pressing `Create project`.

## Add members to myproject

Go to:

[https://172.16.99.1:8443/building-castles/myproject/-/project_members](https://172.16.99.1:8443/building-castles/myproject/-/project_members)

and by pressing `Invite memebers`, add three members as:

- Username: admdevsecops
  Select a role: Owner
- Username: mntdevsecops
  Select a role: Maintainer
- Username: devsecops
  Select a role: Developer

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

Create a local directory to manage the remote repository:

```console
$ git config --global user.email "devsecops@example.com"
(no output)

$ git config --global user.name "devsecops"
(no output)

$ git config --global init.defaultBranch main
(no output)

$ mkdir -v myproject && cd myproject
mkdir: created directory 'myproject'

$ git init
Initialized empty Git repository in /home/kirater/myproject/.git/

$ git remote add origin ssh://git@172.16.99.1:2222/building-castles/myproject.git
(no output)

$ git pull origin main
From ssh://172.16.99.1:2222/building-castles/myproject
 * branch            main       -> FETCH_HEAD

$ git branch --set-upstream-to=origin/main main
branch 'main' set up to track 'origin/main'.

$ ls
README.md
```

## Fix GitLab configuration

Fix the IP address of the GitLab Git clone url.

Using the web interface, as `Administrator` user, change the `Custom Git clone
URL for HTTP(S)` value in the `Visibility and access controls` section at:

[https://172.16.99.1:8443/admin/application_settings/general](https://172.16.99.1:8443/admin/application_settings/general)

Adding the GitLab IP related url, in this case `https://172.16.99.1:8443`
check [DevSecOps-Pipeline-Requirements.md](DevSecOps-Pipeline-Requirements.md)
to find out how to get the IP host.

## Get token for GitLab runner

Get the GitLab runner token registration at:

[https://172.16.99.1:8443/building-castles/myproject/-/settings/ci_cd](https://172.16.99.1:8443/building-castles/myproject/-/settings/ci_cd)

Expanding the "Runners" section and selecting the three dots beside `New
project runner` and finally copying the token, which will be something like
`GR1348941uHeDhAB5DDA8r_5xvxsm`.

## Launch GitLab runner

Set up the runner by launching its container:

```console
$ cd && mkdir -v gitlab-runner
mkdir: created directory 'gitlab-runner'

$ GITLAB_RUNNER_VERSION=v18.4.0
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
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"
Runtime platform                                    arch=amd64 os=linux pid=54 revision=85586bd1 version=16.0.2
Running in system-mode.

WARNING: Support for registration tokens and runner parameters in the 'register' command has been deprecated in GitLab Runner 15.6 and will be replaced with support for authentication tokens. For more information, see https://gitlab.com/gitlab-org/gitlab/-/issues/380872
Registering runner... succeeded                     runner=GR1348941uHeDhAB5
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!

Configuration (with the authentication token) was saved in "/etc/gitlab-runner/config.toml"
```
