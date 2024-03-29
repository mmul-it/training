# Lab | Print what you get before exit

In this lab you will:

1. Create a script named `trap.sh` and paste this content:

   ```bash
   #!/bin/bash

   function trapping {
     echo "Trap is working! Terminating PID $$"
     echo "Now exiting. BYE!" && exit
   }

   trap trapping SIGINT SIGTERM
   echo "Hello! I'm running with PID $$"
   echo "Please send me a SIGNAL to test the trap"

   while true; do
    sleep 10
   done
   ```

   Which trap are you setting up?
   How can you trigger it?

## Solution

1. This script sets up a trap for `SIGINT` and `SIGTERM`. These are the
   equivalent of the `CTRL+C` key combination.
   In order to test the trap, you have to send this signal to the script, after
   launching it:

   ```console
   $ bash trap.sh
   Hello! I'm running with PID 37584
   Please send me a SIGNAL to test the trap
   ```

   Once you press the Ctrl+C key combination it will be showed as `^C` on the
   screen, followed by this text:

   ```console
   Trap is working! Terminating PID 37584
   Now exiting. BYE!
   ```

   Once caught the signal, it exits.
