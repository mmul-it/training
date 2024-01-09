# Lab | First script

In this lab you will:

1. Create an empty file named `myscript.sh`;
2. Edit the file, adding the interpreter (**shebang**) and printing via the
   `echo` command this string: `This is my first script`;
3. Make the script executable and launch it checking the output is what you
   expect;

## Solution

1. You can use touch to create the empty file:

   ```console
   $ touch myscript.sh
   (no output)
   ```

2. Content of the file should be something similar to this:

   ```console
   #!/bin/bash
   echo "This is my first script"
   ```

   First line is the interpreter (shebang), second is the message to be printed.

3. Before launching it, we need to make the script executable:

   ```console
   $ chmod +x myscript.sh
   (no output)
   ```

   And then we can launch it:

   ```console
   $ ./myscript.sh
   This is my first script
   ```
