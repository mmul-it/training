# Lab | Ansible play with roles

In this lab you will:

1. Create a local role named `ipaddr` that will show the host IP address.
2. Include the newly created role inside the `playbook.yaml` playbook.
3. Test the new playbook with `ansible-playbook`.
4. Download the `geerlingguy.nginx` Ansible role from Ansible Galaxy.
5. Include the role inside the `playbook.yaml` playbook.
6. Test everything by using `ansible-playbook`.

## Solution

1. A new and dedicated `roles` directory will be the home for the custom role,
   which can be initialized by using `ansible-galaxy init`, using the
   `--init-path` to specify the destination path:

   ```console
   $ source ansible-venv/bin/activate
   (no output)

   (ansible-venv) $ mkdir -v roles
   mkdir: created directory 'roles'

   (ansible-venv) $ ansible-galaxy init --init-path roles ipaddr
   - Role ipaddr was created successfully
   ```

2. To make this role perform as requested the `roles/ipaddr/tasks/main.yml` file
   should be edited with the task that will print the host IP address:

   ```yaml
   ---
   # tasks file for ipaddr
   - name: Get and print IP addresses
     debug:
       msg: "IP Address: {{ ansible_default_ipv4.address }}"
   ```

   Moving out from the original `playbook.yaml` file the action that now is
   covered by the role, the new content will be:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: true
     vars:
       myvar: "This is the default of my variable"
     roles:
       - ipaddr
     tasks:
       - name: Print the value of myvar
         debug:
           msg: "Value of myvar: {{ myvar }}"
   ```

3. To check the addition use `ansible-playbook`:

   ```console
   (ansible-venv) [kirater@training-adm ~]$ ansible-playbook playbook.yaml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

   PLAY [localhost] *******************************************************************************************************

   TASK [Gathering Facts] *************************************************************************************************
   ok: [localhost]

   TASK [ipaddr : Get and print IP addresses] *****************************************************************************
   ok: [localhost] => {
       "msg": "IP Address: 192.168.99.30"
   }

   TASK [Print the value of myvar] ****************************************************************************************
   ok: [localhost] => {
       "msg": "Value of myvar: This is the default of my variable"
   }

   PLAY RECAP *************************************************************************************************************
   localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

4. The `geerlingguy.nginx` Ansible role is available on Ansible Galaxy and so
   it can be installed using `ansible-galaxy install`:

   ```console
   (ansible-venv) [kirater@training-adm ~]$ ansible-galaxy install geerlingguy.nginx
   Starting galaxy role install process
   - downloading role 'nginx', owned by geerlingguy
   - downloading role from https://github.com/geerlingguy/ansible-role-nginx/archive/3.2.0.tar.gz
   - extracting geerlingguy.nginx to /home/kirater/.ansible/roles/geerlingguy.nginx
   - geerlingguy.nginx (3.2.0) was installed successfully
   ```

5. The role can be included the same way as the custom one, but an additional
   `become: true` directive should be declared in the playbook, because the role
   will need permissions to install software, so to become `root`:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: true
     vars:
       myvar: "This is the default of my variable"
     roles:
       - ipaddr
       - geerlingguy.nginx
     become: true
     tasks:
       - name: Print the value of myvar
         debug:
           msg: "Value of myvar: {{ myvar }}"
   ```

6. Launching the playbook will result in this output:

   ```console
   (ansible-venv) $ ansible-playbook playbook.yaml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

   PLAY [localhost] *************************************************************************************************

   TASK [Gathering Facts] *******************************************************************************************
   ok: [localhost]

   TASK [ipaddr : Get and print IP addresses] ***********************************************************************
   ok: [localhost] => {
       "msg": "IP Address: 192.168.99.30"
   }

   TASK [geerlingguy.nginx : Include OS-specific variables.] ********************************************************
   ok: [localhost]

   TASK [geerlingguy.nginx : Define nginx_user.] ********************************************************************
   ok: [localhost]

   TASK [geerlingguy.nginx : include_tasks] *************************************************************************
   included: /home/kirater/.ansible/roles/geerlingguy.nginx/tasks/setup-RedHat.yml

   TASK [geerlingguy.nginx : Enable nginx repo.] ********************************************************************
   changed: [localhost]

   TASK [geerlingguy.nginx : Ensure nginx is installed.] ************************************************************
   changed: [localhost]

   TASK [geerlingguy.nginx : include_tasks] *************************************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : include_tasks] *************************************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : include_tasks] *************************************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : include_tasks] *************************************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : include_tasks] *************************************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : include_tasks] *************************************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : Remove default nginx vhost config file (if configured***********************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : Ensure nginx_vhost_path exists.] *******************************************************
   ok: [localhost]

   TASK [geerlingguy.nginx : Add managed vhost config files.] *******************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : Remove managed vhost config files.] ****************************************************
   skipping: [localhost]

   TASK [geerlingguy.nginx : Remove legacy vhosts.conf file.] *******************************************************
   ok: [localhost]

   TASK [geerlingguy.nginx : Copy nginx configuration in place.] ****************************************************
   changed: [localhost]

   TASK [geerlingguy.nginx : Ensure nginx service is running as configured.] ****************************************
   changed: [localhost]

   TASK [Print the value of myvar] **********************************************************************************
   ok: [localhost] => {
       "msg": "Value of myvar: This is the default of my variable"
   }

   RUNNING HANDLER [geerlingguy.nginx : reload nginx] ***************************************************************
   changed: [localhost]

   PLAY RECAP *******************************************************************************************************
   localhost                  : ok=13   changed=5    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
   ```

   And the subsequent availability of the NGinx service:

   ```console
   (ansible-venv) $ curl localhost
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

   Note the playbook recap, and then when relaunching it again it will be
   different, confirming that it operated in an idempotent way:

   ```console
   (ansible-venv) $ ansible-playbook playbook.yaml
   ...
   ...
   PLAY RECAP *************************************************************************************************************
   localhost                  : ok=12   changed=0    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0
   ```
