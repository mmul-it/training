# Lab | Writing your first function

In this lab you will:

1. Log into the machine with the credentials you own.
2. Create a new script named `multi_renamer.sh`.
3. Declare a function which requires two parameters: an old file name and a new
   file name.
4. The function must rename the file passed as first parameter using the second
   parameter as new name. Save the parameters and:
   
   - Check if the first one points to an existing file.
   - Check if the second one points to a non existing one.
   - Using the command mv, rename the file.

   The function will not print any output, and will return different statuses
   based on what's gone wrong. Return 0 if everything is ok.
5. The script must read 4 parameters, in this sequence:

   - file1 old name
   - file1 new name
   - file2 old name
   - file2 new name

6. Check if you have those parameters, otherwise print a simple help message.
7. Call the function two times in order to rename files as expected.
8. Print some output for every function call, checking for the function exit
   code and printing something useful to the user.

## Solution

1. Suppose your user is `kirater` and your machine is `machine`:

     ```console
     > ssh kirater@machine
     ```

2-8. The `multi_renamer.sh` script will look similar to this:

     ```bash
     #!/bin/bash
     
     function rename_file () {
     	# 2) Declare a function which require two parameters
     	#    Checking if two parameters was passed
     	if [ $# -ne 2 ]; then
     		return 1
     	fi
     
     	# 3) Saving the parameters as something cohmprensive
     	OLD_FILE=$1
     	NEW_FILE=$2
     
     	# 3.a) Checking if the first parameter exists
     	if ! [ -f $OLD_FILE ]; then
     		return 2
     	fi
     
     	# 3.b) Checking if the second parameter doesn't exists
     	if [ -f $NEW_FILE ]; then
     		return 3
     	fi
     
     	# 3.c) Renaming the file (and checking if everything works well)
     	mv $OLD_FILE $NEW_FILE &>/dev/null
     	if [ $? -ne 0 ]; then
     		return 4
     	fi
     
     	# 3) File renamed, return 0
     	return 0
     }
     
     # 4) Function must read 4 parameters
     if [ $# -ne 4 ]; then
     	# 5) We don't have 4 parameters, showing help
     	echo "usage: $0 <file1 old name> <file1 new name> <file2 old name> <file2 new name>"
     	exit 1
     fi
     
     # 6) Obtaining parameters (and saving those as something cohmprensive)
     FIRST_OLD_FILE=$1
     FIRST_NEW_FILE=$2
     
     SECOND_OLD_FILE=$3
     SECOND_NEW_FILE=$4
     
     # 6) Renaming the first file
     rename_file $FIRST_OLD_FILE $FIRST_NEW_FILE
     # 7) Printing output based on rename_file() exit status
     case $? in
             1) echo "You must pass two not-empty strings as parameter 1 and 2 to this script";;
     	2|3) echo "Problems in file checking. Either $FIRST_OLD_FILE doesn't exists or $FIRST_NEW_FILE already exists";;
     	4) echo "Problem renaming $FIRST_OLD_FILE to $FIRST_NEW_FILE";;
     	*) echo "$FIRST_OLD_FILE -> $FIRST_NEW_FILE";;
     esac
     
     # 6) Renaming the second file
     rename_file $SECOND_OLD_FILE $SECOND_NEW_FILE
     # 7) Printing output based on rename_file() exit status
     case $? in
             1) echo "You must pass two not-empty strings as parameter 3 and 4 to this script";;
     	2|3) echo "Problems in file checking. Either $SECOND_OLD_FILE doesn't exists or $SECOND_NEW_FILE already exists";;
     	4) echo "Problem renaming $SECOND_OLD_FILE to $SECOND_NEW_FILE";;
     	*) echo "$SECOND_OLD_FILE -> $SECOND_NEW_FILE"
     esac
     
     exit 0
     ```
