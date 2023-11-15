Exercise | Print what you get before exit

1. Log into the machine with the credentials you own.
2. Create a script named `trap.sh` and paste this content:

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
