# Exercise | Writing Your First Init Script | Solution

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2-7. Steps from 2 to 7 build a script that will look like this:

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
