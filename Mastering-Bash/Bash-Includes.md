# Lab | Making your own library

In this lab you will:

1. Create a file named `myfunctions1` that will contain a function printing this
   simple text: `This is my first function`.
2. Create a file named `myfunctions2` that will contain a function printing this
   simple text: `This is my second function`.
3. Create a file named `myfunctions.sh` that will include the two libraries and
   call sequentially the two functions.

## Solution

1. File `myfunctions1` should look like this:

   ```bash
   function myfunction1 () {
    echo "This is my first function"
   }
   ```

2. File `myfunctions2` should look like this:

   ```bash
   function myfunction2 () {
    echo "This is my second function"
   }
   ```

3. File `myfunctions.sh` should look like this:

   ```bash
   #!/bin/bash

   source myfunctions1
   source myfunctions2

   myfunction1
   myfunction2
   ```

   Remember to make it executable with:

   ```console
   $ chmod +x myfunctions.sh
   (no output)
   ```

   And then you can launch it:

   ```console
   $ ./myfunctions.sh
   This is my first function
   This is my second function
   ```
