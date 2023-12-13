# Lab | Play with default values and expansions.

In this lab you will:

1. Login into the machine with the credentials you own.
2. Create a file `default_answer.sh` Adding a variable in the script and named
   `ANSWER`. Give it the value of the first positional parameter `$1`.
3. MAke the script print: `The answer to life, the universe and everything is 42`
   The value `42` must be written as a default value if no positional parameter
   is passed during script execution.
4. Using substring removal, print the name of the script you are running.
5. Execute the script and pass a parameter, check the output. Execute the script
   again without passing a parameter, check the difference in the output.

## Solution

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2-4. Resulting file will have this look:

     ```bash
     #!/bin/bash

     # 2) Variable declaration
     ANSWER=$1

     # 3) Print the variable with a default
     echo "The answer to life, the universe and everything is ${ANSWER:=42}"

     # 4) Name of the script without `.sh`
     echo "Name of the script is ${0%%.sh}"
     ```

5. Execute the script twice as requested. Provide a parameter in the first run,
   leave the default value for the second run:

   ```console
   ./default_answer pizza
   The answer to life, the universe and everything is pizza
   Name of the script is ./default_answer

   ./default_answer
   The answer to life, the universe and everything is 42
   Name of the script is ./default_answer
   ```
