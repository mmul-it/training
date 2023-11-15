# Exercise | Reusable Scripts With Positional Parameters | Solutions

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2. The script will look like this:

   ```bash
   #!/bin/bash
   echo "$#"
   echo "$*"
   ```

   Remember that every script should be executable:

   ```console
   [kirater@localhost ~]$ chmod +x ./parameters.sh

   [kirater@localhost ~]$ ./parameters.sh Hello, World!
   2
   Hello, World!
   ```

3. The 'second.sh' will print the second parameter three times:

   ```bash
   #!/bin/bash
   echo "$2"
   echo "$2"
   echo "$2"
   ```

   Output will be:

   ```console
   [kirater@localhost ~]$ chmod +x ./second.sh

   [kirater@localhost ~]$ ./second.sh Hello, World!
   World!
   World!
   World!
   ```

4. The `between.sh` script will look like this:

   ```bash
   #!/bin/bash
   min=$1
   max=$2
   # First: calculate range of random number
   (( range = (max - min) + 1 ))
   # Second: calculate random number as reminder of range
   # (that is between 0 and range-1.
   # plus minimum
   echo $(( ( RANDOM % range ) + min ))
   ```

   Once launched these will be the results:

   ```console
   [kirater@localhost ~]$ chmod +x ./between.sh

   [kirater@localhost ~]$ ./between.sh 1 10
   2

   [kirater@localhost ~]$ ./between.sh 20 30
   29

   [kirater@localhost ~]$ ./between.sh 500 503
   502
   ```

5. The script `grep_passwd.sh` will look like this:

   ```bash
   #!/bin/bash
   grep -i "${1}" /etc/passwd >/dev/null
   echo "$?"
   ```

   Once launched these will be the results:

   ```console
   [kirater@localhost ~]$ chmod +x ./grep_passwd.sh

   [kirater@localhost ~]$ ./grep_passwd.sh kirater
   0

   [kirater@localhost ~]$ ./grep_passwd.sh notpresent
   1
   ```
