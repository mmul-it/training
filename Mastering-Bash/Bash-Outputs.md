# Lab | Filter And Redirect Commands

In this lab you will:

1. Using `/etc/passwd` file, print to standard output only the line referring to
   your user.
2. Print to standard output only the first or last 5 lines of `/etc/group` file.
3. Count how many times the word `bash` occurs in `/etc/passwd` file.
4. Sort, in reverse order, all the users using bash and redirect the output to a
   file called `results.txt`.
5. Append to the previously created file all the lines that contain a `:9` from
   `/etc/group` file.
6. Sort the content of `results.txt` by name.
7. Use the `less` pager to view the content of `/etc/vimrc` and invoke an
   editor to edit the file.

## Solution

1. Using `/etc/passwd` file, print to standard output only the line referring to
   your user:

   ```console
   $ cat /etc/passwd | grep -i kirater
   kirater:x:1000:1000::/home/kirater:/bin/bash
   ```

2. Print to standard output only the first or last 5 lines of `/etc/group` file:

   ```console
   $ tail -5 /etc/group
   rpcuser:x:29:
   cockpit-ws:x:990:
   cockpit-wsinstance:x:989:
   tcpdump:x:72:
   kirater:x:1000:

   $ head -5 /etc/group
   root:x:0:
   bin:x:1:
   daemon:x:2:
   sys:x:3:
   adm:x:4:
   ```

3. Count how many times the word `bash` occurs in `/etc/passwd` file:

   ```console
   $ grep -c bash /etc/passwd
   3
   ```

4. Sort, in reverse order, all the users using bash and redirect the output to
   a file called `results.txt`:

   ```console
   $ grep bash /etc/passwd | sort -r > results.txt
   (no output)
   ```

5. Append to the previously created file all the lines that contain a `:9` from
   `/etc/group` file:

   ```console
   $ grep \:9 /etc/group >> results.txt
   (no output)
   ```

6. Sort the content of `results.txt` by name

   ```console
   $ sort -f results.txt
   chrony:x:992:
   cockpit-ws:x:990:
   cockpit-wsinstance:x:989:
   input:x:999:
   kirater:x:1000:1000::/home/kirater:/bin/bash
   kmem:x:9:
   polkitd:x:996:
   render:x:998:
   root:x:0:0:root:/root:/bin/bash
   setroubleshoot:x:991:
   ssh_keys:x:995:
   sssd:x:993:
   systemd-coredump:x:997:
   unbound:x:994:
   ```

7. Use the less pager to view the content of `/etc/vimrc` and invoke an
   editor to edit the file:

   ```console
   $ less /etc/vimrc
   (less interface opens)
   ```

   and then press `v`. You will see the `less` interface turning into a `vim`
   one, but without the opportunity to make any change, since the file is not
   owned by the `kirater` unprivileged user.
