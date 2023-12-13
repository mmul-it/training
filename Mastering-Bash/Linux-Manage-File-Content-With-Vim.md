# Lab | Manage File Content With Vim

In this lab you will:

1. Log into the machine with the credentials you own.
2. Search for the file named `GPLv2.TXT` under the `/usr/share` directory and copy
   it on the local working dir.
3. Open the local `GPLv2.TXT` file with the `vim` command.
4. Search for the word `General` and count how many times is present.
5. Substitute all the occurrences of the word `General` with `XXXXXXXXX`.
6. Undo your last action.
7. Redo your last action.
8. Search for the word `NO WARRANTY` and add a line before it containing this
   text:

   ```console
   I WILL MAKE YOU PAY FOR EVERYTHING
   ```

9. Set a mark over the sentence `You should have received` and by moving with
   the cursor until the `USA` work delete everything using the mark.
10. Save the file with a new name called `MyScrewedUpGPLv2.TXT`.

## Solution

1. Supposing your user is "kirater" and your machine is "machine":

   ```console
   > ssh kirater@machine
   ```

2. It is doable with a single command:

   ```console
   [kirater@machine ~]$ find /usr/share/licenses/ -name GPLv2.TXT -exec cp {} . \;
   ```

3. Use the vim command:

   ```console
   [kirater@machine ~]$ vim GPLv2.TXT
   ```

4. While in the vim interface type:

   ```console
   /General
   ```

   And by pressing `n` discover how many times the word appears.
5. While in the vim interface type:

   ```console
   :%s/General/XXXXXXXXX/g
   ```

6. While in the vim interface type:

   ```console
   u
   ```

7. While in the vim interface press `Ctrl` and type `r`.
8. While in the vim interface type:

   ```console
   /NO WARRANTY
   ```

   Then press:

   ```console
   O
   ```

   and type:

   ```console
   I WILL MAKE YOU PAY FOR EVERYTHING
   ```

9. While in the vim interface type:

   ```console
   /You should have received
   ```

   Type:

   ```console
   ma
   ```

   Moving the cursor over the end of the `USA` word and then type:

   ```console
   d`a
   ```

10. While in the vim interface type:

    ```console
    :wq MyScrewedUpGPLv2.TXT
    ```
