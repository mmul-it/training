# Lab | Kill a process

In this lab you will:

1. Log into the machine with the credentials you own.
2. Run this command:

   ```bash
   sleep 100
   ```
   
   then pause it.
3. Find out the paused process' PID.
4. Kill the sleep process. Did it work?
5. Kill sleep the hard way, specifying the signal or the code.

## Solution

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2. Launch the sleep command and then press `CTLR+Z`. Result should be:

   ```console
   [kirater@machine ~] $ sleep 100
   ^Z
   [1]+  Stopped                 sleep 100
   ```
   
3. Use `ps -l` to get PIDs of the processes:

   ```console
   [kirater@machine ~]$ ps -l
   F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
   0 S 31700 59195 59194  0  80   0 - 29387 do_wai pts/0    00:00:00 bash
   0 T 31700 59224 59195  0  80   0 - 26989 do_sig pts/0    00:00:00 sleep
   0 R 31700 59231 59195  0  80   0 - 38312 -      pts/0    00:00:00 ps
   ```

4. Killing the process with SIGTERM (the default) won't work:

   ```console
   [kirater@machine ~]$ kill 59224
   [kirater@machine ~]$ ps -l
   F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
   0 S 31700 59195 59194  0  80   0 - 29387 do_wai pts/0    00:00:00 bash
   0 T 31700 59224 59195  0  80   0 - 26989 do_sig pts/0    00:00:00 sleep
   0 R 31700 59482 59195  0  80   0 - 38312 -      pts/0    00:00:00 ps
   ```

   Some processes catch the TERM signal and ignore the command.
5. Let's kill this time using the `SIGKILL` signal name:

   ```console
   [kirater@machine ~]$ kill -s SIGKILL 59224
   [kirater@machine ~]$ ps -l
   F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
   0 S 31700 59195 59194  0  80   0 - 29387 do_wai pts/0    00:00:00 bash
   0 R 31700 59652 59195  0  80   0 - 38312 -      pts/0    00:00:00 ps
   [1]+  Killed                  sleep 100
   ```

   Same can be done with the `-9` signal code (the most common):

   ```   
   [kirater@machine ~]$ kill -9 59723
   [kirater@machine ~]$ ps -l
   F S   UID   PID  PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
   0 S 31700 59195 59194  0  80   0 - 29387 do_wai pts/0    00:00:00 bash
   0 R 31700 59652 59195  0  80   0 - 38312 -      pts/0    00:00:00 ps
   [1]+  Killed                  sleep 100  
   ```

   This time, both times, the process gets killed.
