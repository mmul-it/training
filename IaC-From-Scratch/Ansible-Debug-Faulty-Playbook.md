# Lab | Ansible debug a faulty playbook

1. Create a local file named `error_playbook.yml` with these contents:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: true
     tasks:
       - name: Print a message
         debug:
           msg: "This task has a proper syntax"

       - name: This task has an indentation error
         debug:
           msg: "This task will cause a YAML formatting error"
        - name: This task will cause a syntax error
         debug:
           msg: This task will fail due to missing quotes around the message
   ```

2. Use the `yamllint` tool and `ansible-playbook --syntax-check` to understand
   what's wrong and fix it so that it will be correctly executed by
   `ansible-playbook`.

## Solution

1. Copy and paste the above contents in the `error_playbook.yml` file.

2. Trying to launch the playbook will fail:

   ```console
   (ansible-venv) $ ansible-playbook error_playbook.yml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
   ERROR! We were unable to read either as JSON nor YAML, these are the errors we got from each:
   JSON: Expecting value: line 1 column 1 (char 0)

   Syntax Error while loading YAML.
     did not find expected '-' indicator

   The error appears to be in '/home/kirater/error_playbook.yml': line 12, column 6, but may
   be elsewhere in the file depending on the exact syntax problem.

   The offending line appears to be:

           msg: "This task will cause a YAML formatting error"
        - name: This task will cause a syntax error
        ^ here
   ```

   To start debugging, the `yamllint` package should be installed, by using
   `pip`:

   ```console
   (ansible-venv) $ pip install yamllint
   Collecting yamllint
     Downloading yamllint-1.35.1-py3-none-any.whl (66 kB)
        |████████████████████████████████| 66 kB 1.8 MB/s
   Requirement already satisfied: pyyaml in ./ansible-venv/lib/python3.9/site-packages (from yamllint) (6.0.1)
   Collecting pathspec>=0.5.3
     Downloading pathspec-0.12.1-py3-none-any.whl (31 kB)
   Installing collected packages: pathspec, yamllint
   Successfully installed pathspec-0.12.1 yamllint-1.35.1
   ```

   Using `yamllint` is the simplest thing possible:

   ```console
   (ansible-venv) [kirater@training-adm ~]$ yamllint error_playbook.yml
   error_playbook.yml
     3:17      warning  truthy value should be one of [false, true]  (truthy)
     12:6      error    syntax error: expected <block end>, but found '<block sequence start>' (syntax)
     13:7      error    wrong indentation: expected 7 but found 6  (indentation)
   ```

   To complete the initial debug `ansible-playbook --syntax-check` will show the
   other problems related to this disgraced playbook:

   ```console
   (ansible-venv) [kirater@training-adm ~]$ ansible-playbook --syntax-check error_playbook.yml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
   ERROR! We were unable to read either as JSON nor YAML, these are the errors we got from each:
   JSON: Expecting value: line 1 column 1 (char 0)

   Syntax Error while loading YAML.
     did not find expected '-' indicator

   The error appears to be in '/home/kirater/error_playbook.yml': line 12, column 6, but may
   be elsewhere in the file depending on the exact syntax problem.

   The offending line appears to be:

           msg: "This task will cause a YAML formatting error"
        - name: This task will cause a syntax error
        ^ here
   ```

   Which in fact don't make much difference from the initial error message.

   So, looking fixing the errors, the new version of the playbook, will be:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: true
     tasks:
       - name: Print a message
         debug:
           msg: "This task has a proper syntax"
       - name: This task has an indentation error
         debug:
           msg: "This task will cause a YAML formatting error"
       - name: This task will cause a syntax error
         debug:
           msg: "This task will fail due to missing quotes around the message"
   ```

   The tools will now give a better result:

   ```console
   (ansible-venv) $ yamllint error_playbook.yml

   (ansible-venv) $ ansible-playbook --syntax-check error_playbook.yml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

   playbook: error_playbook.yml
   ```

   And the playbook will be finally executed:

   ```console
   (ansible-venv) $ ansible-playbook error_playbook.yml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

   PLAY [localhost] ****************************************************************************************************

   TASK [Gathering Facts] **********************************************************************************************
   ok: [localhost]

   TASK [Print a message] **********************************************************************************************
   ok: [localhost] => {
       "msg": "This task has a proper syntax"
   }

   TASK [This task has an indentation error] ***************************************************************************
   ok: [localhost] => {
       "msg": "This task will cause a YAML formatting error"
   }

   TASK [This task will cause a syntax error] **************************************************************************
   ok: [localhost] => {
       "msg": "This task will fail due to missing quotes around the message"
   }

   PLAY RECAP **********************************************************************************************************
   localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```
