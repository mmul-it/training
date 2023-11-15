# Exercise | Playing With Pipelines | Solution

1. Supposing your user is "kirater" and your machine is "machine":

   ```console
   > ssh kirater@machine
   ```

2. The command line will be composed as follow:

   ```console
   [kirater@machine ~]$ find /etc | grep a | sort
   ```

   This means:

   - Find all the files in `/etc`.
   - Filter where the `a` char is present.
   - Sort alphabetically the result.

3. To put everything in a file we need to rely on the standard output and
   standard error, so it will be:

   ```console
   [kirater@machine ~]$ find /etc/ 2> etc_errors | grep a | sort > etc_a_file_list
   ```

   So there will be no output and everything should be contained in the files.
   About the redirections note two things:
   - We need the errors from the find command, so `2> etc_errors` should be
     placed RIGHT AFTER the find command, not elsewhere.
   - The full stdout should be at the end.

4. Using the `&&` and `||` combined, the command line will be:

   ```console
   [kirater@machine ~]$ ls /etc/hosts && echo OK || echo KO
   /etc/hosts
   OK
   ```

   In this case && will not be executed.
   You can do the verification like this:

   ```console
   [kirater@machine ~]$ ls /etc/hosts || echo OK && echo OOO
   /etc/hosts
   OOO
   ```

   But things messes up once you use the opposite approach:

   ```console
   [kirater@machine ~]$ ls /etc/nonexistent || echo OK && echo KO
   ls: cannot access '/etc/nonexistent': No such file or directory
   OK
   KO
   ```

   So the first `||` is not skipped, and the && is applied to the echo command,
   which will always be successful.
