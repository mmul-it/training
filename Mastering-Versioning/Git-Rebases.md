# Lab | Use rebase to create a better commit history

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Create a new branch named `mynewfeature` and switch into it.
3. Create a file named `Sixth.txt` with content
   `Branch mynewfeature modification for the Sixth.txt commit.`.
4. Commit the file with the message `Sixth.txt mynewfeature commit`.
5. Switch back to branch `main` and create a file named `Sixth.txt` with content
   `Branch main modification for the Sixth.txt commit.`.
6. Commit the file with the message `Sixth.txt commit`.
7. Use rebase to include the commit coming from the `mynewfeature` branch into
   `main`, by resolving the conflicts and make a clean commit history.

## Solution

1. Repository should be available in the `myrepo` folder. To use it as a workdir
   just use `cd`:

   ```console
   $ cd /git/myrepo
   (no output)

   $ git status
   On branch main
   nothing to commit, working tree clean
   ```

2. To create a new branch simply use `git branch` and `git switch`:

   ```console
   $ git branch mynewfeature
   (no output)

   $ git switch mynewfeature
   Switched to branch 'mynewfeature'
   ```

   Note that using `git checkout -b mynewfeature` would have been equivalent.

3. To prepare the file to be committed:

   ```console
   $ echo "Branch mynewfeature modification for the Sixth.txt commit." > Sixth.txt
   (no output)
   ```

4. To commit the file in the branch:

   ```console
   $ git add Sixth.txt

   $ git commit -m "Sixth.txt mynewfeature commit" -m "Description of the mynewfeature Sixth commit."

   $ git log --oneline --graph
   * 7cb2eb8 (HEAD -> mynewfeature) Sixth.txt mynewfeature commit
   *   50594f9 (origin/main, main) Merge branch 'myfeature'
   |\
   | * fef7458 (origin/myfeature, myfeature) Fifth.txt myfeature commit
   * | 203c056 Fifth.txt commit
   |/
   * df8294c Fourth.txt commit
   * d523228 Adding .gitignore
   * cb10f6d Third commit
   * ecef636 Second commit
   * 7966140 First commit
   ```

5. To switch back to branch `main` and prepare a new file to be committed:

   ```console
   $ git switch main
   Switched to branch 'main'

   $ echo "Branch main modification for the Sixth.txt commit." > Sixth.txt
   ```

6. To commit the file into branch `main`:

   ```console
   $ git add Sixth.txt

   $ git commit -m "Sixth.txt commit" -m "Description of the Sixth commit."
   [main 408ed5d] Sixth.txt commit
    1 file changed, 1 insertion(+)
    create mode 100644 Sixth.txt
   ```

7. Instead what we did before, which was using `git merge`, we will use rebase,
   that in any case will give us the indication of the conflict that we'll need
   to address:

   ```console
   $ git status
   On branch main
   Your branch is ahead of 'origin/main' by 1 commit.
     (use "git push" to publish your local commits)

   $ git rebase mynewfeature
   Auto-merging Sixth.txt
   CONFLICT (add/add): Merge conflict in Sixth.txt
   error: could not apply e713973... Sixth.txt commit
   hint: Resolve all conflicts manually, mark them as resolved with
   hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
   hint: You can instead skip this commit: run "git rebase --skip".
   hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
   Could not apply e713973... Sixth.txt commit
   ```

   The status clearly tells where the problem is:

   ```console
    $ git status
    interactive rebase in progress; onto 7cb2eb8
    Last command done (1 command done):
       pick e713973 Sixth.txt commit
    No commands remaining.
    You are currently rebasing branch 'main' on '7cb2eb8'.
      (fix conflicts and then run "git rebase --continue")
      (use "git rebase --skip" to skip this patch)
      (use "git rebase --abort" to check out the original branch)

    Unmerged paths:
      (use "git restore --staged <file>..." to unstage)
      (use "git add <file>..." to mark resolution)
         both added:      Sixth.txt

    no changes added to commit (use "git add" and/or "git commit -a")

    $ cat Sixth.txt
    <<<<<<< HEAD
    Branch mynewfeature modification for the Sixth.txt commit.
    =======
    Branch main modification for the Sixth.txt commit.
    >>>>>>> e713973 (Sixth.txt commit)
   ```

   As before, to solve the conflict it will be sufficient to edit the file by
   leaving the modifications we care about:

   ```console
   $ echo "Branch main and mynewfeature modifications for the Sixth.txt commit." > Sixth.txt
   (no output)
   ```

   And then add the file to the staged ones and continue the rebase:

   ```console
   $ git add Sixth.txt
   (no output)

   $ git rebase --continue
   (vim editor opens)
   ```

   The content of the editable file will be something like this:

   ```console
   Sixth.txt commit

   Description of the Sixth commit.

   # Please enter the commit message for your changes. Lines starting
   # with '#' will be ignored, and an empty message aborts the commit.
   #
   # interactive rebase in progress; onto 7cb2eb8
   # Last command done (1 command done):
   #    pick e713973 Sixth.txt commit
   # No commands remaining.
   # You are currently rebasing branch 'main' on '7cb2eb8'.
   #
   # Changes to be committed:
   #       modified:   Sixth.txt
   #
   ```

   Which is actually the existing commit message with its description.
   By saving it (with `:wq`) the rebase will be completed:

   ```console
   $ git rebase --continue
   [detached HEAD c7aa82d] Sixth.txt commit
    1 file changed, 1 insertion(+), 1 deletion(-)
   Successfully rebased and updated refs/heads/main
   ```

   Looking at the history, this time we have a more linear and comprehensible
   one, compared to the merged one:

   ```console
   $ git log --oneline --graph
   * c7aa82d (HEAD -> main) Sixth.txt commit
   * 7cb2eb8 (mynewfeature) Sixth.txt mynewfeature commit
   *   50594f9 (origin/main, main) Merge branch 'myfeature'
   |\
   | * fef7458 (origin/myfeature, myfeature) Fifth.txt myfeature commit
   * | 203c056 Fifth.txt commit
   |/
   * acce6eb Fourth.txt commit
   * d523228 Adding .gitignore
   * cb10f6d Third commit
   * ecef636 Second commit
   * 7966140 First commit
   ```

   Before moving on, let's push everything on remote, to reflect everything also
   on the bare repository:

   ```console
   $ git push
   Enumerating objects: 7, done.
   Counting objects: 100% (7/7), done.
   Delta compression using up to 16 threads
   Compressing objects: 100% (6/6), done.
   Writing objects: 100% (6/6), 703 bytes | 703.00 KiB/s, done.
   Total 6 (delta 2), reused 0 (delta 0), pack-reused 0
   To /git/myrepo-bare/
      50594f9..c7aa82d  main -> main

   $ git log --oneline --graph
   * c7aa82d (HEAD -> main, origin/main) Sixth.txt commit
   * 7cb2eb8 (mynewfeature) Sixth.txt mynewfeature commit
   *   50594f9 Merge branch 'myfeature'
   |\
   | * fef7458 (origin/myfeature, myfeature) Fifth.txt myfeature commit
   * | 203c056 Fifth.txt commit
   |/
   * acce6eb Fourth.txt commit
   * d523228 Adding .gitignore
   * cb10f6d Third commit
   * ecef636 Second commit
   * 7966140 First commit
   ```
