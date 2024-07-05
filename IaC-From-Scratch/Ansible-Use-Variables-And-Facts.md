# Lab | Ansible use variables and facts

In this lab you will:

1. Create a local playbook named `playbook.yaml` that will act on localhost.
2. Define a task that will get and print the IP addresses.
3. Print the value of a variable named `myvar` and if this has not being passed,
   use a default value of 'This is the default of my variable'.
4. Test everything by using `ansible-playbook`, without defining any inventory.

## Solution

1. The first lines of the `playbook.yaml` file will define a `hosts` entry
   pointing to `localhost` and `gather_facts` set to `yes`, otherwise it will
   be not possible to get host facts:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: true
   ```

2. The IP address can be obtained by the `ansible_default_ipv4.address` fact, so
   to print it a `debug task should do the work:

   ```yaml
       - name: Get and print IP addresses
         debug:
           msg: "IP Address: {{ ansible_default_ipv4.address }}"
   ```

3. The `myvar` variable should be declared inside the `vars` section of the
   playbook, this will be its default value:

   ```yaml
   vars:
     myvar: "This is the default of my variable"
   ```

   To print it, it will be possible to use `debug` again:

   ```yaml
       - name: Print the value of myvar
         debug:
           msg: "Value of myvar: {{ myvar }}"
   ```

   The complete file should look like this:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: true
     vars:
       myvar: "This is the default of my variable"
     tasks:
       - name: Get and print IP addresses
         debug:
           msg: "IP Address: {{ ansible_default_ipv4.address }}"

       - name: Print the value of myvar
         debug:
           msg: "Value of myvar: {{ myvar }}"
   ```

4. With the playbook in place, the execution is just a matter of invoking
   `ansible-playbook`:

   ```console
   (ansible-venv) $ ansible-playbook playbook.yaml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

   PLAY [localhost] *************************************************************************************************

   TASK [Gathering Facts] *******************************************************************************************
   ok: [localhost]

   TASK [Get and print IP addresses] ********************************************************************************
   ok: [localhost] => {
       "msg": "IP Address: 192.168.99.30"
   }

   TASK [Print the value of myvar] **********************************************************************************
   ok: [localhost] => {
       "msg": "Value of myvar: This is the default of my variable"
   }

   PLAY RECAP *******************************************************************************************************
   localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

   The first run will correctly print the default value, but by overriding the
   value on the command line, the output changes:

   ```console
   (ansible-venv) $ ansible-playbook -e "myvar='My custom value'" playbook.yaml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

   PLAY [localhost] ****************************************************************************************************

   TASK [Gathering Facts] **********************************************************************************************
   ok: [localhost]

   TASK [Get and print IP addresses] ***********************************************************************************
   ok: [localhost] => {
       "msg": "IP Address: 192.168.99.30"
   }

   TASK [Print the value of myvar] *************************************************************************************
   ok: [localhost] => {
       "msg": "Value of myvar: My"
   }

   PLAY RECAP **********************************************************************************************************
   localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

   This second launch gives two important hints:

   1. Command line arguments have priority over playbook variables.
   2. Command line arguments that defines string variables with spaces need a
      quote including the entire declaration.
