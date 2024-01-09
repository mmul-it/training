# Lab | Writing Your First Init Script

In this lab you will:

1. Create a script which require one of these parameters:

   - start
   - stop
   - restart
   - status

2. The script must print some sort of help if launched without parameters.
3. The script must validate the passed parameter and print error if isn't in
   the list provided before.
4. The script must create a file named `/tmp/${0}.pid` with the current process
   PID inside.
5. You must check every possible status:

   - On start: don't start if already started.
   - On stop: don't stop if not yet running.
   - On restart: don't stop if not yet running, then start.

6. On status, the script must print a readable status and the PID saved inside
   the file (if running).

## Solution

1. ->
2. ->
3. ->
4. ->
5. ->
6. Steps from 2 to 7 build a script that will look like this:

   ```bash
   #!/bin/bash

   if [ $# -ne 1 ]; then
       echo "usage: $0 <start|stop|restart|status>"
   else
       COMMAND=$1
       CURRENT_PID=$$
       PID_FILE="/tmp/${0}.pid"

       case $COMMAND in
           start)
               if [ -f $PID_FILE ]; then
                   echo "$0 already running"
               else
                   echo $CURRENT_PID > $PID_FILE
               fi
               ;;
           stop)
               if [ -f $PID_FILE ]; then
                   rm -f $PID_FILE
               else
                   echo "$0 not running"
               fi
               ;;
           restart)
               if [ -f $PID_FILE ]; then
                   rm -f $PID_FILE
               fi
               echo $CURRENT_PID > $PID_FILE
               ;;
           status)
               if [ -f $PID_FILE ]; then
                   echo "$0 is running ($(cat $PID_FILE))"
               else
                   echo "$0 not running"
               fi
               ;;
           *)
               echo "Unknown parameter"
               ;;
       esac
   fi
   ```
