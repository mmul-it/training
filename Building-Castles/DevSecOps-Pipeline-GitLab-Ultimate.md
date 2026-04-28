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

Launch the GitLab Enterprise instance using the `gitlab/gitlab-ee` container,
exposing these ports (Host/Container):

- 8443:8443 -> the `https` GitLab Ultimate UI port (with an auto generated
  self-signed certificate).
- 2222:22 -> the `ssh` port for git actions.
- 5050:5050 -> the GitLab Ultimate Container Registry service port.

```console
$ GITLAB_VERSION=18.8.2-ee.0
(no output)

$ GITLAB_HOME=$PWD/gitlab \
  docker run \
  --detach \
  --name gitlab \
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

## Get token for GitLab runner

Get the GitLab runner token registration at:

[https://172.16.99.1:8443/admin/runners](https://172.16.99.1:8443/admin/runners)

By selecting the three dots beside `Create instance runner` and finally copying
the token, which will be something like `GR1348941uHeDhAB5DDA8r_5xvxsm`.

## Launch GitLab runner

Set up the runner by launching its container:

```console
$ GITLAB_RUNNER_VERSION=v18.4.0
(no output)

$ GITLAB_RUNNER_HOME=$PWD/gitlab-runner
(no output)

$ docker run --detach \
  --name gitlab-runner \
  --privileged \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume $GITLAB_RUNNER_HOME/gitlab-runner:/etc/gitlab-runner \
  --volume $GITLAB_HOME/config/ssl:/etc/gitlab-runner/certs \
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
