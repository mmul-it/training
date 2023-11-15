# Exercise | Playing With File Permissions

1. Create a directory called as your user that contains a file
   called testfile1 in /tmp
2. Check file permissions and, using the numeric annotation, remove 
   all permission bits, except for the owner
3. With another user, remove testfile1
4. With the initial user, set full permission to all on testfile1
5. Switch user and re-try step 3
6. Something's not quite right. We set 777, it should work!
   Let's check the /tmp directory permissions. What do you notice?
