# Lab | Reusable Scripts With Positional Parameters

In this lab you will:

1. Write a script named `parameters.sh` to print:

   - The number of parameters.
   - All the parameters as a string.

2. Write `second.sh` to print just the second parameter three times.
3. Write `between.sh` to use first two arguments as min and max for random
   number generation.
4. Write `grep_passwd.sh`, that search argument 1 into `/etc/passwd` and print
   only the exit code. A `0` means found, a `1` means not found.
   In the script, redirect the standard output of `grep` to `/dev/null`;

## Solution

1. The script will look like this:

   ```bash
   #!/bin/bash
   echo "$#"
   echo "$*"
   ```

   Remember that every script should be executable:

   ```console
   $ chmod +x ./parameters.sh
   (no output)

   $ ./parameters.sh Hello, World!
   2
   Hello, World!
   ```

2. The `second.sh` script will print the second parameter three times:

   ```bash
   #!/bin/bash
   echo "$2"
   echo "$2"
   echo "$2"
   ```

   Output will be:

   ```console
   $ chmod +x ./second.sh
   (no output)

   $ ./second.sh Hello, World!
   World!
   World!
   World!
   ```

3. The `between.sh` script will look like this:

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
   $ chmod +x ./between.sh
   (no output)

   $ ./between.sh 1 10
   2

   $ ./between.sh 20 30
   29

   $ ./between.sh 500 503
   502
   ```

4. The script `grep_passwd.sh` will look like this:

   ```bash
   #!/bin/bash
   grep -i "${1}" /etc/passwd >/dev/null
   echo "$?"
   ```

   Once launched these will be the results:

   ```console
   $ chmod +x ./grep_passwd.sh
   (no output)

   $ ./grep_passwd.sh kirater
   0

   $ ./grep_passwd.sh notpresent
   1
   ```
