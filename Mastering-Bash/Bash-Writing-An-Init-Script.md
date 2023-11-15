# Exercise | Writing Your First Init Script

1. Log into the machine with the credentials you own.
2. Create a script which require one of these parameters:

   - start
   - stop
   - restart
   - status

3. The script must print some sort of help if launched without parameters.
4. The script must validate the passed parameter and print error if isn't in
   the list provided before.
5. The script must create a file named `/tmp/${0}.pid` with the current process
   PID inside.
6. You must check every possible status:

   - On start: don't start if already started.
   - On stop: don't stop if not yet running.
   - On restart: don't stop if not yet running, then start.

7. On status, the script must print a readable status and the PID saved inside
   the file (if running).
