# Lab | Find Specific Files

In this lab you will:

1. Find which `find` command options makes you able to list all the files owned
   by a specific user.
2. Look for all the files owned by the user `polkitd` under the `/usr`
   directory.
3. Examine the results: did you noticed anything strange?
4. Find which `find` command options makes you able to list all the files
   with a specific name.
5. Look for all the files with `.sh` file extension under the `/etc`
   directory.
6. Find which `find` command options makes you able to list all the files
   that are executable.
7. Look for all the executable files under the `/etc` directory.

## Solution

1. Using `man find` you can find that the option is `user`.
2. You should use:

   ```console
   $ find /usr -user polkitd
   find: ‘/usr/share/migrationtools’: Permission denied
   /usr/share/polkit-1/rules.d
   find: ‘/usr/share/polkit-1/rules.d’: Permission denied
   find: ‘/usr/libexec/initscripts/legacy-actions/auditd’: Permission denied
   find: ‘/usr/local/etc/ldapscripts’: Permission denied
   find: ‘/usr/local/lib/ldapscript’: Permission denied
   find: ‘/usr/local/lib/ldapscripts’: Permission denied
   ```

3. There are several `Permission denied` errors due to the fact that the
   unprivileged user can't access some directories under `/usr`;
4. The option is `name`.
5. You should use:

   ```console
   $ find /etc -name *.sh
   find: ‘/etc/openldap/slapd.d’: Permission denied
   find: ‘/etc/openldap/cacerts’: Permission denied
   /etc/kernel/postinst.d/51-dracut-rescue-postinst.sh
   ...
   ...
   ```

6. The option is `-executable` and you need also to specify `-file` to exclude
   directories from the results.
7. You should use:

   ```console
   $ find /etc -executable -type f
   find: ‘/etc/openldap/slapd.d’: Permission denied
   find: ‘/etc/openldap/cacerts’: Permission denied
   /etc/kernel/postinst.d/51-dracut-rescue-postinst.sh
   ...
   ...
   ```
