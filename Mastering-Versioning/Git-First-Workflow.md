# Lab | Play with commit, reset and checkout

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Configure the Git user name `Kirater Dev` and the email
   `kirater@kiratech.it`.
3. Verify the contents of the `.git/config` file to check the updated data.
4. Create three sample commits each one containing a text file named:
   | File name    | Commit message | Extended commit message           |
   |--------------|----------------|-----------------------------------|
   | `First.txt`  | First commit   | Description of the First commit.  |
   | `Second.txt` | Second commit  | Description of the Second commit. |
   | `Third.txt`  | Third commit   | Description of the Third commit.  |
5. Create a file named `Fourth.txt` with some text and check its status via
   `git status`, add it to the staged files list and the use reset to remove it.
6. Modify the previosuly created `First.txt`, check its status using `git diff`,
   and finally use `git checkout` to restore it.

## Solution

1. In the first exercise you should have a created a repository under the
   `myrepo` folder. To use it as a workdir just use `cd`:

   ```console
   $ cd /git/myrepo

   $ git status
   On branch main

   No commits yet

   nothing to commit (create/copy files and use "git add" to track)
   ```

2. To make sure Git knows about yourself (for commit metadata):

   ```console
   $ git config --global user.name "Kirater Dev"
   (no output)

   $ git config --global user.email "kirater@kiratech.it"
   (no output)
   ```

3. From now all the commits by default will be associated with the previously
   set user because inside the `~/.gitconfig` file the metadata are stored:

   ```console
   $ cat ~/.gitconfig
   [user]
        name = Kirater Dev
        email = kirater@kiratech.it
   ```

   Note that this file lives in the home directory of the user, because we
   added the `--global` option to the `git config` command. Without it, it
   would have been added just to the repository, inside the `.git/config` file.

4. This can be easily achieved with a bash loop:

   ```console
   $ for FILEn in First Second Third; \
       do echo "Contents of the $FILEn file." > $FILEn\.txt; \
       git add $FILEn\.txt; \
       git commit -m "$FILEn commit" -m "Description of the $FILEn commit."; \
       done
   [main (root-commit) b0137b3f775e] First commit
    1 file changed, 1 insertion(+)
    create mode 100644 First.txt
   [main 183d68d0e5a6] Second commit
    1 file changed, 1 insertion(+)
    create mode 100644 Second.txt
   [main 663a19897697] Third commit
    1 file changed, 1 insertion(+)
    create mode 100644 Third.txt
   ```

   And created commits can be checked with `git log`:

   ```console
   $ git log
   commit 663a198976973892e39f732eb38fdf82890440b3 (HEAD -> main)
   Author: Kirater Dev <kirater@kiratech.it>
   Date:   Tue Mar 5 14:39:03 2024 +0000

       Third commit

       Description of the Third commit.

   commit 183d68d0e5a61462d3827adbf2fbff3182aade16
   Author: Kirater Dev <kirater@kiratech.it>
   Date:   Tue Mar 5 14:39:03 2024 +0000

       Second commit

       Description of the Second commit.

   commit b0137b3f775ea21303b3766282aa89e17134abd1
   Author: Kirater Dev <kirater@kiratech.it>
   Date:   Tue Mar 5 14:39:03 2024 +0000

       First commit

       Description of the First commit.
   ```

5. To create the `Fourth.txt` file use:

   ```console
   $ echo "Contents of the Fourth file." > Fourth.txt
   (no output)
   ```

   And check its status, ending in adding it with `git add`:

   ```console
   $ git status
   On branch main

   No commits yet

   Untracked files:
     (use "git add <file>..." to include in what will be committed)
         Fourth.txt

   nothing added to commit but untracked files present (use "git add" to track)

   $ git add Fourth.txt

   $ git status
   On branch main

   No commits yet

   Changes to be committed:
     (use "git rm --cached <file>..." to unstage)
        new file:   Fourth.txt
   ```

   Now use `git reset` to move it out from the staged file list:

   ```console
   $ git reset Fourth.txt

   $ git status
   On branch main

   No commits yet

   Untracked files:
     (use "git add <file>..." to include in what will be committed)
        Fourth.txt

   nothing added to commit but untracked files present (use "git add" to track)
   ```

   Remove the file to cleanup:

   ```console
   $ rm -v Fourth.txt
   removed 'Fourth.txt'
   ```

6. Modify `First.txt` and check diffs:

   ```console
   $ echo "My new content" > First.txt

   $ git diff First.txt
   diff --git a/First.txt b/First.txt
   index 049230b..6d5e86c 100644
   --- a/First.txt
   +++ b/First.txt
   @@ -1 +1 @@
   -Contents of the First file.
   +My new content
   ```

   Finally restore the file by using `git checkout`:

   ```console
   $ git checkout First.txt
   Updated 1 path from the index

   $ git status
   On branch main
   nothing to commit, working tree clean

   $ cat First.txt
   Contents of the First file.
   ```
