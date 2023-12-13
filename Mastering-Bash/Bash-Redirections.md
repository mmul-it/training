# Lab | Bash Redirections

In this lab you will:

1. Log into the machine with the credentials you own.
2. Print the string `Redirect STDOUT` to a file called `output_data` in your
   HOMEDIR.
3. Append string `This is a simple output redirection.` to the same file.
   Make sure that both strings are there.
4. List the content of the `/usr/bin` directory and append the result to
   the same file.
5. Print the content of the `$HOME/output_data` file and pipe it to the
   `less` command (use `q` to exit from `less` output).
6. List the content of `/root` directory and print the STDOUT to the shell
   and, eventually, STDERR to the file `listing_log` in your HOMEDIR.
   Check if any error has occurred.
7. If any error has been logged, list the content of `/tmp` directory and
   redirect both STDOUT and STDERR to the file `listing_log` in your HOMEDIR,
   appending data.

## Solution

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
