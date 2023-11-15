# Exercise | Play with default values and expansions | Solution

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
