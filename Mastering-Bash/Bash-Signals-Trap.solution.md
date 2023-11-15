Exercise | Print what you get before exit | Solution

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh mmul@machine
   ```

2. This script sets up a trap for `SIGINT` and `SIGTERM`. These are the
   equivalent of the `CTRL+C` key combination.
   In order to test the trap, you have to send this signal to the script, after
   launching it:

   ```console
   > bash trap.sh
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
