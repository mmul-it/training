# Exercise | Examine behaviour with faulty command in script

1. Log into the machine with the credentials you own.
2. Write a script which ask for a file as a parameter.
3. The script must check if the file exists.
4. If it works, then try to copy the file in some positions:

   - `/var/run`
   - `$HOME`
   - `/tmp`
   - `/`

   Failed command must not show errors, but you must save the exit code.

5. After the copy, the script must report which command had some problems.
6. The script must exit with 0 if it has copied the file at least in one of
   the positions.
