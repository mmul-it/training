# Lab | Play with Git branches and resolve merge conflicts

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Create a new branch named `myfeature` and switch into it.
3. Create a file named `Fifth.txt` with content
   `Branch myfeature modification for the Fifth.txt commit.`.
4. Commit the file with the message `Fifth.txt myfeature commit`.
5. Switch back to branch `main` and create a file named `Fifth.txt` with content
   `Branch main modification for the Fifth.txt commit.`.
6. Commit the file with the message `Fifth.txt commit`.
7. Merge branch `myfeature` into `main`, by resolving the conflicts.

## Solution

1. Repository should be available in the `myrepo` folder. To use it as a workdir
   just use `cd`:

   ```console
   ~ $ cd myrepo
   (no output)

   ~/myrepo $ git status
   On branch main
   nothing to commit, working tree clean
   ```

2. To create a new branch simply use `git branch` and `git switch`:

   ```console
   ~/myrepo $ git branch myfeature
   (no output)

   ~/myrepo $ git switch myfeature
   Switched to branch 'myfeature'
   ```

   Note that using `git checkout -b myfeature` would have been equivalent.

3. To prepare the file to be committed:

   ```console
   ~/myrepo $ echo "Branch myfeature modification for the Fifth.txt commit." > Fifth.txt
   (no output)
   ```

4. To commit the file in the branch:

   ```console
   ~/myrepo $ git add Fifth.txt

   ~/myrepo $ git commit -m "Fifth.txt myfeature commit" -m "This is the description of the myfeature Fifth commit."
   [myfeature 7f002cd] Fifth.txt myfeature commit
    1 file changed, 1 insertion(+)
    create mode 100644 Fifth.txt

   ~/myrepo $ git log --oneline
   7f002cd (HEAD -> myfeature) Fifth.txt myfeature commit
   acce6eb (main) Fourth.txt commit
   d523228 Adding .gitignore
   cb10f6d Third commit
   ecef636 Second commit
   7966140 First commit
   ```

5. To switch back to branch `main` and prepare a new file to be committed:

   ```console
   ~/myrepo $ git switch main
   Switched to branch 'main'

   ~/myrepo $ echo "Branch main modification for the Fifth.txt commit." > Fifth.txt
   ```

6. To commit the file into branch `main`:

   ```console
   ~/myrepo $ git add Fifth.txt

   ~/myrepo $ git commit -m "Fifth.txt commit" -m "This is the description of the Fifth commit."
   [main 408ed5d] Fifth.txt commit
    1 file changed, 1 insertion(+)
    create mode 100644 Fifth.txt
   ```

7. It is time to merge, but a conflict will appear:

   ```console
   ~/myrepo $ git merge myfeature
   Auto-merging Fifth.txt
   CONFLICT (add/add): Merge conflict in Fifth.txt
   Automatic merge failed; fix conflicts and then commit the result.
   ```

   The status tells clearly where is the problem:

   ```console
   ~/myrepo $ git status
   On branch main
   You have unmerged paths.
     (fix conflicts and run "git commit")
     (use "git merge --abort" to abort the merge)

   Unmerged paths:
     (use "git add <file>..." to mark resolution)
        both added:      Fifth.txt

   no changes added to commit (use "git add" and/or "git commit -a")

   ~/myrepo $ cat Fifth.txt
   <<<<<<< HEAD
   Branch main modification for the Fifth.txt commit.
   =======
   Branch myfeature modification for the Fifth.txt commit.
   >>>>>>> myfeature
   ```

   To solve the conflict it will be sufficient to edit the file by leaving the modifications we care about:

   ```console
   ~/myrepo $ echo "Branch main and myfeature modifications for the Fifth.txt commit." > Fifth.txt
   (no output)
   ```

   And then add the file to the staged ones:

   ```console
   ~/myrepo $ git add Fifth.txt

   ~/myrepo $ git merge --continue
   (vim editor opens)
   ```

   The content of the editable file will be something like this:

   ```console
   Merge branch 'myfeature'

   # Conflicts:
   #       Fifth.txt
   #
   # It looks like you may be committing a merge.
   # If this is not correct, please run
   #       git update-ref -d MERGE_HEAD
   # and try again.


   # Please enter the commit message for your changes. Lines starting
   # with '#' will be ignored, and an empty message aborts the commit.
   #
   # On branch main
   # All conflicts fixed but you are still merging.
   #
   # Changes to be committed:
   #       modified:   Fifth.txt
   #
   ```

   By saving it (with `:wq`) the merge will be completed:

   ```console
   ~/myrepo $ git merge --continue
   [main 38fceae] Merge branch 'myfeature'

   ~/myrepo $ git log --oneline
   38fceae (HEAD -> main) Merge branch 'myfeature'
   408ed5d Fifth.txt commit
   7f002cd (myfeature) Fifth.txt myfeature commit
   acce6eb Fourth.txt commit
   d523228 Adding .gitignore
   cb10f6d Third commit
   ecef636 Second commit
   7966140 First commit

   ~/myrepo $ git log --oneline --graph
   *   38fceae (HEAD -> main) Merge branch 'myfeature'
   |\
   | * 7f002cd (myfeature) Fifth.txt myfeature commit
   * | 408ed5d Fifth.txt commit
   |/
   * acce6eb Fourth.txt commit
   * d523228 Adding .gitignore
   * cb10f6d Third commit
   * ecef636 Second commit
   * 7966140 First commit
   ```
