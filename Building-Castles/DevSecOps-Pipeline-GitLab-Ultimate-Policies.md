# Lab | Configure users, a group, a project and a default group policy

In this lab you will set up all the users and a group for the GitLab Ultimate
instance, configure a local `myproject` working directory and activating a
default group policy.

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

## Define a default group policy

As Admin, inside our GitLab Ultimate installation we created the
`building-castles` group, and we are going to configure for every project in it
a policy that will prevent security problems from being merged.

To activate a policy that will execute a scan to check for secrets, move into
the group Policies page:

[https://172.16.99.1:8443/groups/building-castles/-/security/policies](https://172.16.99.1:8443/groups/building-castles/-/security/policies)

Press the `New policy` button, and under `Scan execution policy` press
the `Select policy` button, and fill with these content the relative fields:

- Name: `Check for Secrets exposure`.
- Policy scope: Apply this policy to `all projects in this group` `without
  exceptions`.
- Scan execution configuration:
  - Configuration type: `Template`
  - Scan execution strategy: `Merge Request Security`
  - Security scans to execute: `Secret Detection`

Pressing `Configure with a merge request` will take you to the `Update
security policies` page.

After pressing the `Merge` button a policy checker for the entire group will be
in place.

## Simulate merge request problem

It is crucial to understand that the correct workflow always starts with a
branch creation.

We are going to create a custom branch and push a change that exposes a
password:

```console
$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean

$ git checkout -b secret-detection-test
Switched to a new branch 'secret-detection-test'

$ echo 'PASSWORD=password1!' > reserved.env
(no output)

$ git add . && git commit -m "Add secret exposing file"
[secret-detection-test 075b54c] Add secret exposing file
 1 file changed, 1 insertion(+)
 create mode 100644 reserved.env

$ git push --set-upstream origin secret-detection-test
Warning: Permanently added '[172.16.99.1]:2222' (ED25519) to the list of known hosts.
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 4 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 301 bytes | 301.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0), pack-reused 0 (from 0)
remote: 
remote: To create a merge request for secret-detection-test, visit:
remote:   https://172.16.99.1:8443/building-castles/myproject/-/merge_requests/new?merge_request%5Bsource_branch%5D=secret-detection-test
remote: 
To ssh://172.16.99.1:2222/building-castles/myproject.git
 * [new branch]      secret-detection-test -> secret-detection-test
branch 'secret-detection-test' set up to track 'origin/secret-detection-test'.
```

As the `DevSecOps` user go to the `myproject` project page:

[https://172.16.99.1:8443/building-castles/myproject](https://172.16.99.1:8443/building-castles/myproject)

You should see a message like:

> You pushed to first-test at building-castles / myproject 1 minute ago

With a `Create merge request` button. Click on it.

In the merge request summary page under `Assignees` and `Reviewers` select
`MntDevSecOps` and press `Create merge request`.

TODO: understand why no problems is detected even if the policy is in place.
