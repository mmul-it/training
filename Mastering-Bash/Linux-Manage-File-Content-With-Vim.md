# Exercise | Manage File Content With Vim

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
