# Exercise | Bash Redirections | Solution

1. Supposing your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2. Check for path, then print the string:

   ```console
   [kirater@machine ~]$ pwd
   /home/kirater
   [kirater@machine ~]$ echo "Redirect STDOUT" > ~/output_data
   ```

3. Append the string and check the content of the file:

   ```console
   [kirater@machine ~]$ echo "This is a simple output redirection." >> ~/output_data
   [kirater@machine ~]$ cat ~/output_data
   Redirect STDOUT
   This is a simple output redirection.
   ```

4. Execute the command to list folder content and append the output

   ```console
   [kirater@machine ~]$ ls -l /usr/bin >> ~/output_data
   ```

5. Execute the command to show file content and pipe it as standard input
   for the less command.
   Then press "q" to exit:

   ```console
   [kirater@machine ~]$ cat ~/output_data | less
   # Exercise 003 - Redirect STDOUT
   This is a simple output redirection.
   total 782364
   -rwxr-xr-x.  1 root root       111376 ott 17 09:38 [
   -rwxr-xr-x.  1 root root           43 feb  2  2019 7z
   ...
   ```

   *press `q` to exit the output*

6. Execute the command to list /root content and redirect the STDOUT
   and STDERR as requested.
   Then check the content of ~/listing_log:

   ```console
   [kirater@machine ~]$ ls -l /root 2>~/listing_log
   [kirater@machine ~]$ cat ~/listing_log
   ls: cannot open directory '/root': Permission denied
   ```

7. List content of /tmp directory and redirect as requested:

   ```console
   [kirater@machine ~]$ ls -l /tmp &>>~/listing_log
   [kirater@machine ~]$ cat ~/listing_log
   ls: cannot open directory '/root': Permission denied
   total 8
   drwx------. 2 kirater kirater 120 nov  7 08:53 tempfile.1
   drwx------. 2 kirater kirater 120 nov  7 08:53 tempfile.2
   ...
   ```

   *Note that content of `/tmp` will differ*.
