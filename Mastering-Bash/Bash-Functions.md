# Exercise | Writing your first function

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
