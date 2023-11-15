# Exercise | Examine behaviour with faulty command in script | Solution

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2-6. With your favourite editor, open a script named `copier.sh`. The content of
     the script will be something like this:

     ```bash
     #!/bin/bash
     
     if [ $# -ne 1 ]; then
     	echo "usage: $0 <filename>"
     	exit 1
     fi
     
     THEFILE=$1
     
     # 3) if it does not exists (or isn't a file), exit:
     
     if ! [ -f $THEFILE ]; then
     	echo "$THEFILE not found"
     	exit 2
     fi
     
     # 4) Try copying files in different positions (saving the status):
     
     cp $THEFILE /var/run &>/dev/null
     VAR_RUN_COPY=$?
     
     cp $THEFILE $HOME &>/dev/null
     HOME_COPY=$?
     
     cp $THEFILE /tmp &>/dev/null
     TMP_COPY=$?
     
     cp $THEFILE / &>/dev/null
     ROOT_COPY=$?
     
     # 5) Check for the different exit statuses:
     
     if [ $VAR_RUN_COPY -ne 0 ]; then
     	echo "Cannot copy $FILE in /var/run"
     fi
     if [ $HOME_COPY -ne 0 ]; then
     	echo "Cannot copy $FILE in $HOME"
     fi
     if [ $TMP_COPY -ne 0 ]; then
     	echo "Cannot copy $FILE in /tmp"
     fi
     if [ $ROOT_COPY -ne 0 ]; then
     	echo "Cannot copy $FILE in /"
     fi
     
     # 6) Exit 0 if at least one of the exit statuses are 0:
     
     if [ $VAR_RUN_COPY -eq 0 ] || [ $HOME_COPY -eq 0 ] ||
        [ $TMP_COPY -eq 0 ] || [ $ROOT_COPY -eq 0 ]; then
     	exit 0
     fi
     
     exit 1
     ```
