# Exercise | Bash Redirections

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
