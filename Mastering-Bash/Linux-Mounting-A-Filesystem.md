# Lab | Mounting a filesystem

In this lab you will:

1. View active mounts.
2. Create a mountpoint called `ram_disk`, and mount (as root) a new filesystem:
  - type `tmpfs`.
  - options `size=512k`.
  - device `tmpfs`.
3. Verify mount of `ram_disk`.
4. Create a file into the new filesystem, and list it.
5. Umount (as root) `ram_disk`.
6. Verify `ram_disk` is now empty and remove mountpoint.

## Solution

1. View active mounts:

   ```console
   $ cat /proc/mounts
   sysfs /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
   proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
   devtmpfs /dev devtmpfs rw,nosuid,size=8040596k,nr_inodes=2010149,mode=755 0 0
   securityfs /sys/kernel/security securityfs rw,nosuid,nodev,noexec,relatime 0 0
   [...]
   ```

   or

   ```console
   $ mount
   sysfs on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
   proc on /proc type proc (rw,nosuid,nodev,noexec,relatime)
   devtmpfs on /dev type devtmpfs (rw,nosuid,size=8040596k,nr_inodes=2010149,mode=755.
   securityfs on /sys/kernel/security type securityfs (rw,nosuid,nodev,noexec,relatime)
   [...]
   ```

2. Create a mountpoint called `ram_disk`, and mount (as root) a new filesystem:

   - type tmpfs
   - options size=512k
   - device tmpfs

   ```console
   $ mkdir ram_disk
   (no output)

   $ sudo mount -t tmpfs -o size=512k tmpfs ram_disk
   (no output)
   ```

3. Verify mount of `ram_disk`:

   ```console
   $ grep ram_disk /proc/mounts
   tmpfs /home/kirater/ram_disk tmpfs rw,relatime,size=524288k 0 0
   ```

   or

   ```console
   $ mount | grep ram_disk
   tmpfs on /home/kirater/ram_disk type tmpfs (rw,relatime,size=524288k)
   ```

4. Create a file into the new filesystem, and list it:

   ```console
   $ touch ram_disk/test_file
   (no output)

   $ ls ram_disk
   test_file
   ```

5. Umount (as root) `ram_disk`:

   ```console
   $ sudo umount ram_disk
   (no output)
   ```

6. Verify `ram_disk` is now empty and remove mountpoint:

   ```console
   $ ls ram_disk/
   (no output)

   $ rmdir ram_disk
   (no output)
   ```
