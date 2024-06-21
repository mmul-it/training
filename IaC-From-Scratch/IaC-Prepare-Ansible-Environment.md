# Lab | Prepare the Python Ansible Virtual Environment

In this lab you will:

1. Create a local Python environment named `ansible-venv` and activate the
   environment.
2. Install `ansible` using `pip`.
3. Enable the host to be reachable via `ssh` by itself.
4. Test the connection by using `ansible` to check the uptime command.

## Solution

1. Create the folder dedicated to the container build:

   ```console
   $ python -m venv ansible-venv
   (no output)

   $ source ansible-venv/bin/activate
   (no output)

   (ansible-venv) $ uptime
   15:07:20 up 21 days,  4:04,  1 user,  load average: 0.65, 0.55, 0.51
   ```

2. Inside the Virtual Environment the `pip` command can be used to install
   `ansible`:

   ```console
   (ansible-venv) $ pip install ansible
   Collecting ansible
     Downloading ansible-8.7.0-py3-none-any.whl (48.4 MB)
     ...
   Collecting ansible-core~=2.15.7
     Downloading ansible_core-2.15.12-py3-none-any.whl (2.3 MB)
     ...
   Successfully installed MarkupSafe-2.1.5 PyYAML-6.0.1 ansible-8.7.0 ansible-core-2.15.12 cffi-1.16.0 cryptography-42.0.8 importlib-resources-5.0.7 jinja2-3.1.4 packaging-24.1 pycparser-2.22 resolvelib-1.0.1
   ```

   To test that the tool is now available, check its version:

   ```console
   (ansible-venv) $ ansible --version
   ansible [core 2.15.12]
     config file = None
     configured module search path = ['/home/kirater/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
     ansible python module location = /home/kirater/ansible-venv/lib64/python3.9/site-packages/ansible
     ansible collection location = /home/kirater/.ansible/collections:/usr/share/ansible/collections
     executable location = /home/kirater/ansible-venv/bin/ansible
     python version = 3.9.18 (main, Jan 24 2024, 00:00:00) [GCC 11.4.1 20231218 (Red Hat 11.4.1-3)] (/home/kirater/ansible-venv/bin/python)
     jinja version = 3.1.4
     libyaml = True
   ```

3. To test the connection the user should be enabled to connect to the host via
   SSH, so a key pair should be generated, and enabled:

   ```console
   (ansible-venv) $ ssh-keygen
   Generating public/private rsa key pair.
   Enter file in which to save the key (/home/kirater/.ssh/id_rsa):
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   Your identification has been saved in /home/kirater/.ssh/id_rsa
   Your public key has been saved in /home/kirater/.ssh/id_rsa.pub
   The key fingerprint is:
   SHA256:mp5G1SOtCOnP1sJKI5Z5HAq6EQ2h5WeRaeeVRDESXUc kirater@training-adm
   The key's randomart image is:
   +---[RSA 3072]----+
   |. . .oo==+..E    |
   |.+  +...+. .     |
   |o ..o+ . o       |
   | o oo . o +      |
   |o .... oSo .     |
   |.o =..oo.        |
   |o * ==o.         |
   | + + oB..        |
   |.   .+o.         |
   +----[SHA256]-----+

   (ansible-venv) $ cat .ssh/id_rsa.pub >> .ssh/authorized_keys
   (no output)

   (ansible-venv) $ ssh kirater@172.18.0.1 uptime
    12:15:23 up  1:24,  1 user,  load average: 0.65, 1.06, 1.08

   (ansible-venv) $ ssh localhost uptime
   The authenticity of host 'localhost (::1)' can't be established.
   ED25519 key fingerprint is SHA256:iTEE4wDtjcC+AJ0MeF5BJeCFYPbRLnFWJqYlOYjE3l4.
   This key is not known by any other names
   Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
   Warning: Permanently added 'localhost' (ED25519) to the list of known hosts.
    15:17:44 up 21 days,  4:15,  1 user,  load average: 0.24, 0.34, 0.42

   (ansible-venv) $ ssh localhost uptime
    15:18:39 up 21 days,  4:16,  1 user,  load average: 0.30, 0.33, 0.41
   ```

4. Now that the user is enabled to connect via SSH, it is possible to use the
   `ansible` command, with the `command` module (`--module-name`) passing the
   name of the command to be executed as argumend (`--args`):

   ```console
   $ ansible localhost --module-name command --args uptime
   [WARNING]: No inventory was parsed, only implicit localhost is available
   localhost | CHANGED | rc=0 >>
    15:20:20 up 21 days,  4:17,  1 user,  load average: 0.47, 0.35, 0.41
   ```

   The output shows that the connection was made and the command executed, even
   if there is not (yet) an inventory, because we are connecting to `localhost`.
