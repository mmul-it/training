# Exercise | Playing With The Shell | Solution

1. Supposing your user is "kirater" and your machine is "machine":

```console
> ssh kirater@machine
```

2. You should print the contents of the SHELL environmental variable:

```console
[kirater@machine ~]$ echo $SHELL
/bin/bash
```

3. Use the "pwd" command:

```console
[kirater@machine ~]$ pwd
/home/kirater
```

4. Use the "mkdir" command:

```console
[kirater@machine ~]$ mkdir Test
```

5. Use the "cd" command:

```console
[kirater@machine ~]$ cd Test
```

And then the "ls -la" command:

```console
[kirater@machine Test]$ ls -la
total 8
drwxrwxr-x  2 kirater kirater 4096 nov  4 16:35 .
drwxr-xr-x 57 kirater kirater 4096 nov  4 16:35 ..
```

Directory is owned by the "kirater" user and the "kirater" group.

6. Use the "touch" command:

```console
[kirater@machine ~]$ touch Testfile
```

7. Use again the "ls -la" command:

```console
[kirater@machine Test]$ ls -la
total 8
drwxrwxr-x  2 kirater kirater 4096 nov  4 16:36 .
drwxr-xr-x 57 kirater kirater 4096 nov  4 16:35 ..
-rw-rw-r--  1 kirater kirater    0 nov  4 16:36 Testfile
```

File is owned by th "kirater" user and the "kirater" group.

8. Use the "cd" command:

```console
[kirater@machine ~]$ cd /etc
```

And then the "ls -la" command:

```console
[kirater@machine etc]$ ls -la
total 1648
drwxr-xr-x 184 root root    12288 nov  4 10:51 .
drwxr-xr-x  26 root root     4096 nov  3 22:27 ..
...
...
```

Directory is owned by "root" user and "root" group.

9. Use the "touch" command:

```console
[kirater@machine etc]$ touch Testfile
touch: cannot touch 'Testfile': Permission denied
```

10. No, because an unprivileged user can't write on directories he doesn't own.
