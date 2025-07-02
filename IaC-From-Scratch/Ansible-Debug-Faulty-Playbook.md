# Lab | Ansible debug a faulty playbook

1. Create a local file named `error_playbook.yml` with these contents:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: yes
     tasks:
       - name: Print a message
         debug:
           msg: "This task has a proper syntax"

       - name: Bad indentation task
           debug:
             msg: "This task has a bad indentation"

       - name: Missing colon
         debug
           msg: "This will trigger a missing colon error"

       - name: Too many spaces after dash
           debug:
               msg: "This line has excessive indentation"

       - name: Trailing spaces    
         debug:    
           msg: "This has trailing spaces on keys and lines"
   ```

2. Use the `yamllint` tool and `ansible-playbook --syntax-check` to understand
   what's wrong and fix it so that it will be correctly executed by
   `ansible-playbook`.

## Solution

1. Copy and paste the above contents in the `error_playbook.yml` file.

2. Trying to launch the playbook will fail:

   ```console
   $ source ansible-venv/bin/activate
   (no output)

   (ansible-venv) $ ansible-playbook error_playbook.yml
   [WARNING]: No inventory was parsed, only implicit localhost is available
   [WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'
   ERROR! We were unable to read either as JSON nor YAML, these are the errors we got from each:
   JSON: Expecting value: line 1 column 1 (char 0)

   Syntax Error while loading YAML.
     mapping values are not allowed in this context. mapping values are not allowed in this context
     in "<unicode string>", line 10, column 14

   The error appears to be in '/home/rasca/error_playbook.yml': line 10, column 14, but may
   be elsewhere in the file depending on the exact syntax problem.

   The offending line appears to be:

       - name: Bad indentation task
           debug:
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
     mapping values are not allowed in this context. mapping values are not allowed in this context
     in "<unicode string>", line 10, column 14

   The error appears to be in '/home/rasca/error_playbook.yml': line 10, column 14, but may
   be elsewhere in the file depending on the exact syntax problem.

   The offending line appears to be:

       - name: Bad indentation task
           debug:
                ^ here
   ```

   Which in fact don't make much difference from the initial error message.

   Fixing the errors will be a matter of understanding the `yamllint` and
   `ansible-playbook --syntax-check` output messages, and fix one after another
   all the problems.

   The fixed version of the playbook, will be:

   ```yaml
   ---
   - hosts: localhost
     gather_facts: true
     tasks:
       - name: Print a message
         debug:
           msg: "This task has a proper syntax"

       - name: Bad indentation task
         debug:
           msg: "This task has a bad indentation"

       - name: Missing colon
         debug:
           msg: "This will trigger a missing colon error"

       - name: Too many spaces after dash
         debug:
           msg: "This line has excessive indentation"

       - name: Trailing spaces
         debug:
           msg: "This has trailing spaces on keys and lines"
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
   ```
