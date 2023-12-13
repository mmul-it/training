# Lab | Making your own library

In this lab you will:

1. Log into the machine with the credentials you own.
2. Create a file named `myfunctions1` that will contain a function printing this
   simple text: `This is my first function`.
3. Create a file named `myfunctions2` that will contain a function printing this
   simple text: `This is my second function`.
3. Create a file named `myfunctions.sh` that will include the two libraries and
   call sequentially the two functions.

## Solution

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2. File `myfunctions1` should look like this:

   ```bash
   function myfunction1 () {
    echo "This is my first function"
   }
   ```

3. File `myfunctions2` should look like this:

   ```bash
   function myfunction2 () {
    echo "This is my second function"
   }
   ```

4. File `myfunctions.sh` should look like this:

   ```bash
   #!/bin/bash

   source myfunctions1
   source myfunctions2

   myfunction1
   myfunction2
   ```

   Remember to make it executable with:

   ```console
   [kirater@machine ~]$ chmod +x myfunctions.sh
   ```
   And then you can launch it:

   ```console
   [kirater@machine ~]$ ./myfunctions.sh
   This is my first function
   This is my second function
   ```
