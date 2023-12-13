# Lab | Reusable Scripts With Positional Parameters

In this lab you will:

1. Log into the machine with the credentials you own.
2. Write a script named `parameters.sh` to print:

   - The number of parameters.
   - All the parameters as a string.

3. Write `second.sh` to print just the second parameter three times.
4. Write `between.sh` to use first two arguments as min and max for random
   number generation.
5. Write `grep_passwd.sh`, that search argument 1 into `/etc/passwd` and print
   only the exit code. A `0` means found, a `1` means not found.
   In the script, redirect the standard output of `grep` to `/dev/null`;

## Solution

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
