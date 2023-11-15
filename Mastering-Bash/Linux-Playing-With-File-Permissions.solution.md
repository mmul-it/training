# Exercise | Playing With File Permissions | Solution

1. Create a directory called as your user that contains a file                  
   called testfile1 in `/tmp`:

   ```console
   [kirater@localhost ~]$ mkdir /tmp/kirater
   [kirater@localhost ~]$ cd /tmp/kirater/
   [kirater@localhost kirater]$ touch testfile1
   ```

2. Check permissions, remove all permission on the file except for owner:

   ```console
   [kirater@localhost kirater]$ ls -l
   -rw-r----- 1 kirater kirater 0 Dec  2 16:33 testfile1

   [kirater@localhost kirater]$ chmod 0600 testfile1

   [kirater@localhost kirater]$ ls -l
   -rw------- 2 kirater kirater 60 Dec  2 16:33 testfile1
   ```

3. Switching account and trying to remove file `testfile1`:

   ```console
   [kirater@localhost kirater]$ su - kirater2

   [kirater2@localhost ~]$ cd /tmp/kirater

   [kirater2@localhost kirater]$ rm testfile1
   rm: remove write-protected regular empty file 'testfile1'? y
   rm: cannot remove 'testfile1': Permission denied
   ```

4. Re-assign permissions:

   ```console
   [kirater2@localhost kirater]$ exit
   [kirater@localhost kirater]$ chmod 0777 testfile1

   [kirater@localhost scratch]$ ls -l
   -rwxrwxrwx 1 kirater kirater 0 Dec  2 16:41 testfile1
   ```

5. Trying to remove again:

   ```console
   [kirater@localhost kirater]$ su - kirater2

   [kirater2@localhost ~]$ cd /tmp/kirater

   [kirater2@localhost kirater]$ ls -l
   -rwxrwxrwx 1 kirater kirater 0 Dec  2 16:41 testfile1

   [kirater2@localhost kirater]$ rm testfile1
   rm: cannot remove 'testfile1': Permission denied
   ```

6. Check /tmp permissions:

   ```console
   [kirater2@localhost scratch]$ ls -ld /tmp/
   drwxrwxrwt 34 root root 1720 Dec  2 17:00 /tmp/
   ```

   /tmp has the sticky bit enabled! This means that, despite the full access, 
   we cannot remove testfile1 because kirater2 is not the owner.
