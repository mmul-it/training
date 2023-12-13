# Lab | Filter And Redirect Commands

In this lab you will:

1. Log into the machine with the credentials you own;
2. Using `/etc/passwd` file, print to standard output only the line referring to
   your user.
3. Print to standard output only the first or last 5 lines of `/etc/group` file.
4. Count how many times the word `bash` occurs in `/etc/passwd` file.
5. Sort, in reverse order, all the users using bash and redirect the output to a
   file called `results.txt`.
6. Append to the previously created file all the lines that contain a `:9` from
   `/etc/group` file.
7. Sort the content of `results.txt` by name.
8. Use the `less` pager to view the content of `/var/log/boot.log` and invoke an
   editor to edit the file.

## Solution

1. Log into the machine with the credentials you own.

2. Using `/etc/passwd` file, print to standard output only the line referring to
   your user:

   ```console
   cat /etc/passwd | grep -i kirater
   ```

3. Print to standard output only the first or last 5 lines of `/etc/group` file:

   ```console
   [kirater@machine ~]$ tail -5 /etc/group
   [kirater@machine ~]$ head -5 /etc/group
   ```

4. Count how many times the word `bash` occurs in `/etc/passwd` file:

   ```console
   [kirater@machine ~]$ grep -c bash /etc/passwd
   3
   ```

5. Sort, in reverse order, all the users using bash and redirect the output to
   a file called `results.txt`:

   ```console
   grep bash /etc/passwd | sort -r > results.txt
   ```

6. Append to the previously created file all the lines that contain a `:9` from
   `/etc/group` file:

   ```console
   grep \:9 /etc/group >> results.txt
   ```

7. Sort the content of `results.txt` by name

   ```console
   [kirater@machine ~]$ sort -f results.txt
   ```

8. Use the less pager to view the content of `/var/log/boot.log` and invoke an
   editor to edit the file:

   ```console
   less /var/log/boot.log
   ```

   and then press `v`.
