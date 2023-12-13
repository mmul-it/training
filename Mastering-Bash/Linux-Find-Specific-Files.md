# Lab | Find Specific Files

In this lab you will:

1. Log into the machine with the credentials you own.
2. Find which `find` command options makes you able to list all the files owned
   by a specific user.
3. Look for all the files owned by the user `polkitd` under the `/usr`
   directory.
4. Examine the results: did you noticed anything strange?
5. Find which `find` command options makes you able to list all the files
   with a specific name.
6. Look for all the files with `.sh` file extension under the `/etc`
   directory.
7. Find which `find` command options makes you able to list all the files
   that are executable.
8. Look for all the executable files under the `/etc` directory.

## Solution

1. Supposing your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2. The option is `user`.
3. You should use:

   ```console
   [kirater@machine ~]$ find /usr -user polkitd
   find: ‘/usr/share/migrationtools’: Permission denied
   /usr/share/polkit-1/rules.d
   find: ‘/usr/share/polkit-1/rules.d’: Permission denied
   find: ‘/usr/libexec/initscripts/legacy-actions/auditd’: Permission denied
   find: ‘/usr/local/etc/ldapscripts’: Permission denied
   find: ‘/usr/local/lib/ldapscript’: Permission denied
   find: ‘/usr/local/lib/ldapscripts’: Permission denied
   ```

4. There are several `Permission denied` errors due to the fact that the
   unprivileged user can't access some directories under `/usr`;
5. The option is `name`.
6. You should use:

   ```console
   [kirater@machine ~]$ find /etc -name *.sh
   find: ‘/etc/openldap/slapd.d’: Permission denied
   find: ‘/etc/openldap/cacerts’: Permission denied
   /etc/kernel/postinst.d/51-dracut-rescue-postinst.sh
   ...
   ...
   ```

7. The option is `-executable` and you need also to specify `-file` to exclude
   directories from the results.
8. You should use:

   ```console
   [kirater@machine ~]$ find /etc -executable -type f
   find: ‘/etc/openldap/slapd.d’: Permission denied
   find: ‘/etc/openldap/cacerts’: Permission denied
   /etc/kernel/postinst.d/51-dracut-rescue-postinst.sh
   ...
   ...
   ```
