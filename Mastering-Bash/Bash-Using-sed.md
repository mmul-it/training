# Lab | Substitutions with sed

In this lab you will:

Use the file `results.txt` from the [Bash-Outputs.md](Bash-Outputs.md) exercise.

1. Substitute first match of `root` with `love`.
2. Substitute every match of `root` with `love` (remember the option `g`).
3. Substitute every digit with a dot (remember range).
4. Substitute every number with a single dot (remember escape in pattern).
5. Substitute every number with a single dot, then remove the pattern `:.`. 
   (substitute with empty string).
6. Substitute until the `:` with the string `<s_user>` if line begins with `s`.

## Solution

Use the file `results.txt` from the [Bash-Outputs.md](Bash-Outputs.md) exercise.

1. Substitute first match of `root` with `love`:

   ```console
   [kirater@machine ~]$ cat results.txt | sed 's/root/love/'
   test1:x:1000:100:Utenza di test1:/home/test1:/bin/bash
   system1:x:1001:100:Utenza di test2:/home/system1:/bin/bash
   love:x:0:0:root:/root:/bin/bash
   kmem:x:9:
   nobody:x:99:
   input:x:999:
   polkitd:x:998:
   ssh_keys:x:997:
   postdrop:x:90:
   chrony:x:996:
   ```

2. Substitute every match of `root` with `love` (remember the option `g`):

   ```console
   [kirater@machine ~]$ cat results.txt | sed 's/root/love/g'
   test1:x:1000:100:Utenza di test1:/home/test1:/bin/bash
   system1:x:1001:100:Utenza di test2:/home/system1:/bin/bash
   love:x:0:0:love:/love:/bin/bash
   kmem:x:9:
   nobody:x:99:
   input:x:999:
   polkitd:x:998:
   ssh_keys:x:997:
   postdrop:x:90:
   chrony:x:996:
   ```

3. Substitute every digit with a dot (remember range):

   ```console
   [kirater@machine ~]$ cat results.txt | sed 's/[0-9]/./g'
   test.:x:....:...:Utenza di test.:/home/test.:/bin/bash
   system.:x:....:...:Utenza di test.:/home/system.:/bin/bash
   root:x:.:.:root:/root:/bin/bash
   kmem:x:.:
   nobody:x:..:
   input:x:...:
   polkitd:x:...:
   ssh_keys:x:...:
   postdrop:x:..:
   chrony:x:...:
   ```

4. Substitute every number with a single dot (remember escape in pattern):

   ```console
   [kirater@machine ~]$ cat results.txt | sed 's/[0-9]\+/./g'
   test.:x:.:.:Utenza di test.:/home/test.:/bin/bash
   system.:x:.:.:Utenza di test.:/home/system.:/bin/bash
   root:x:.:.:root:/root:/bin/bash
   kmem:x:.:
   nobody:x:.:
   input:x:.:
   polkitd:x:.:
   ssh_keys:x:.:
   postdrop:x:.:
   chrony:x:.:
   ```

5. Substitute every number with a single dot, then remove the pattern `:.`
   (substitute with empty string):

   ```console
   [kirater@machine ~]$ cat results.txt | sed 's/[0-9]\+/./g' | sed 's/:\.//g'
   test.:x:Utenza di test.:/home/test.:/bin/bash
   system.:x:Utenza di test.:/home/system.:/bin/bash
   root:x:root:/root:/bin/bash
   kmem:x:
   nobody:x:
   input:x:
   polkitd:x:
   ssh_keys:x:
   postdrop:x:
   chrony:x:
   ```

   or equivalent:

   ```console
   [kirater@machine ~]$ cat results.txt | sed 's/[0-9]\+/./g ; s/:\.//g'
   cat results.txt | sed 's/[0-9]\+/./g ; s/:\.//g'
   test.:x:Utenza di test.:/home/test.:/bin/bash
   system.:x:Utenza di test.:/home/system.:/bin/bash
   root:x:root:/root:/bin/bash
   kmem:x:
   nobody:x:
   input:x:
   polkitd:x:
   ssh_keys:x:
   postdrop:x:
   chrony:x:
   ```

6. Substitute until the `:` with the string `<s_user>` if line begins with `s`

   ```console
   [kirater@machine ~]$ cat results.txt | sed 's/^s[^:]\+/<s_user>/'
   test1:x:1000:100:Utenza di test1:/home/test1:/bin/bash
   <s_user>:x:1001:100:Utenza di test2:/home/system1:/bin/bash
   root:x:0:0:root:/root:/bin/bash
   kmem:x:9:
   nobody:x:99:
   input:x:999:
   polkitd:x:998:
   <s_user>:x:997:
   postdrop:x:90:
   chrony:x:996:
   ```
