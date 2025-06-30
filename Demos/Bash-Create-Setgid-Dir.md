# Demonstration | Create a setgid directory

As root, create a directory `/test`:

```console
$ mkdir /test
(no output)
```

Show permission of the directory:

```console
$ ls -ld /test
drwxr-x--- 2 root root 4096 Dec  3 18:39 /test
```

Enter the directory and create an empty file:

```console
$ cd /test/
(no output)

$ touch prova
(no output)

$ ls -l
total 0
-rw-r----- 1 root root 0 Dec  3 18:39 prova
```

This file is owned by root. Remove that:

```console
[root@mmul-bash-course test]# rm prova
rm: remove regular empty file 'prova'? y
```

Change the proprietary group of the `/test` directory and apply the setgid bit:

```console
$ chgrp students /test
(no output)

$ ls -ld /test
drwxr-x--- 2 root students 4096 Dec  3 18:40 /test

$ chmod g+s /test
(no output)

$ ls -ld /test
drwxr-s--- 2 root students 4096 Dec  3 18:40 /test
```

You can now notice and `s` in the group permissions

Try touching another file

```console
$ touch prova
(no output)
```

Show the file ownership:

```console
$ ls -l
total 0
-rw-r----- 1 root students 0 Dec  3 18:42 prova
```

The file proprietary group is student. This can be really handy to managed
shared directories betweeen users.
