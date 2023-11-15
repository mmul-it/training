# Exercise | First script | Solution

1. Supposing your user is "kirater" and your machine is "machine":

   ```console
   > ssh kirater@machine
   ```

2. You can use touch to create the empty file:

   ```console
   [kirater@machine ~]$ touch myscript.sh
   ```

3. Content of the file should be something similar to this:

   ```console
   #!/bin/bash
   echo "This is my first script"
   ```

   First line is the interpreter (shebang), second is the message to be printed.

4. Before launching it, we need to make the script executable:

   ```console
   [kirater@machine ~]$ chmod +x myscript.sh
   ```

   And then we can launch it:

   ```console
   [kirater@machine ~]$ ./myscript.sh
   This is my first script
   ```
