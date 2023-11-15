# Exercise | Manage File Content With Vim | Solution

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
