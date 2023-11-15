# Exercise | Reusable Scripts With Positional Parameters

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
