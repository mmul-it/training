# Lab | Playing With The Shell

In this lab you will:

1. Determine which shell you are using.
2. Dermine in which directory you have been logged into.
3. Create a new directory named "Test".
4. Move into this directory. Which user owns it? Which group?
5. Create a new empty file named "Testfile".
6. Who owns the file? Which group?
7. Move into the "/etc" directory. Which user owns it? Which group?
8. Create a new file named "Testfile".
9. Did you succeed? Why not?

## Solution

1. You should print the contents of the SHELL environmental variable:

   ```console
   $ echo $SHELL
   /bin/bash
   ```

2. Use the "pwd" command:

   ```console
   $ pwd
   /home/kirater
   ```

3. Use the "mkdir" command:

   ```console
   $ mkdir Test
   (no output)
   ```

4. Use the "cd" command:

   ```console
   $ cd Test
   (no output)
   ```

   And then the "ls -la" command:

   ```console
   $ ls -la
   total 8
   drwxrwxr-x  2 kirater kirater 4096 nov  4 16:35 .
   drwxr-xr-x 57 kirater kirater 4096 nov  4 16:35 ..
   ```

   Directory is owned by the "kirater" user and the "kirater" group.

5. Use the "touch" command:

   ```console
   $ touch Testfile
   (no output)
   ```

6. Use again the "ls -la" command:

   ```console
   $ ls -la
   total 8
   drwxrwxr-x  2 kirater kirater 4096 nov  4 16:36 .
   drwxr-xr-x 57 kirater kirater 4096 nov  4 16:35 ..
   -rw-rw-r--  1 kirater kirater    0 nov  4 16:36 Testfile
   ```

   File is owned by the `kirater` user and the `kirater` group.

7. Use the "cd" command:

   ```console
   $ cd /etc
   (no output)
   ```

   And then the "ls -la" command:

   ```console
   $ ls -la
   total 1648
   drwxr-xr-x 184 root root    12288 nov  4 10:51 .
   drwxr-xr-x  26 root root     4096 nov  3 22:27 ..
   ...
   ...
   ```

   Directory is owned by "root" user and "root" group.

8. Use the "touch" command:

   ```console
   $ touch Testfile
   touch: cannot touch 'Testfile': Permission denied
   ```

9. No, because an unprivileged user can't write on directories he doesn't own.
