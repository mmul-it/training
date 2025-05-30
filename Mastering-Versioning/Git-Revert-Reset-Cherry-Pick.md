# Lab | Learn git revert, git reset and cherry-pick

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Create a new branch named `learngit1` and swith into it.
3. Create three sample commits each one containing a text file named:
   | File name     | Commit message | Extended commit message                        |
   |---------------|----------------|------------------------------------------------|
   | `Nineth.txt`  | Nineth commit  | This is the description of the Nineth commit.  |
   | `Eighth.txt`  | Eighth commit  | This is the description of the Eighth commit.  |
   | `Seventh.txt` | Seventh commit | This is the description of the Seventh commit. |
   Note that the order of the commits should be mantained, so the sequence will
   be: `Nineth commit`, `Eighth commit`, and `Seventh commit`.
4. Move back to `main` branch and merge the entire `learngit1` branch into
   `main`.
5. Revert `Nineth commit`.
6. Reset `HEAD` so that everything will move back to the original `main` branch
   status, and no one of the three commits and the revert will be part of the
   history anymore.
7. Now use `git cherry-pick` to add the commits in the correct order, so:
   `Seventh commit`, `Eighth commit`, and `Nineth commit`.

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
   $ git branch learngit1
   (no output)

   $ git switch learngit1
   Switched to branch 'learngit1'
   ```

   Note that using `git checkout -b learngit1` would have been equivalent.

3. This can be easily achieved with a bash loop:

   ```console
   $ for FILEn in Nineth Eighth Seventh; \
       do echo "Contents of the $FILEn file." > $FILEn\.txt; \
       git add $FILEn\.txt; \
       git commit -m "$FILEn commit" -m "This is the description of the $FILEn commit."; \
       done
   [learngit1 a17a661] Nineth commit
    1 file changed, 1 insertion(+)
    create mode 100644 Nineth.txt
   [learngit1 36404de] Eighth commit
    1 file changed, 1 insertion(+)
    create mode 100644 Eighth.txt
   [learngit1 24f4de7] Seventh commit
    1 file changed, 1 insertion(+)
    create mode 100644 Seventh.tx
   ```

4. Let's move back to `main` and merge (there should be no conflicts):

   ```console
   $ git checkout main
   Switched to branch 'main'
   Your branch is up to date with 'origin/main'.

   $ git merge learngit1
   Updating c7aa82d..24f4de7
   Fast-forward
    Eighth.txt  | 1 +
    Nineth.txt  | 1 +
    Seventh.txt | 1 +
    3 files changed, 3 insertions(+)
    create mode 100644 Eighth.txt
    create mode 100644 Nineth.txt
    create mode 100644 Seventh.txt

   $ git log --oneline --graph
   * 24f4de7 (HEAD -> main, learngit1) Seventh commit
   * 36404de Eighth commit
   * a17a661 Nineth commit
   * c7aa82d (origin/main) Sixth.txt commit
   ...
   ...
   ```

5. The nineth commit is `a17a661` and it created the `Nineth.txt` file, so by
   reverting it a new commit will be created that will remove `Nineth.txt`:

   ```console
   $ ls Nineth.txt
   Nineth.txt

   $ git revert a17a661
   [main 056d8a4] Revert "Nineth commit"
    1 file changed, 1 deletion(-)
    delete mode 100644 Nineth.txt
   ```

   The `git revert` command causes the vim editor to open so that the new
   commit can be customized. Typing `:wq` will save the commit as is, making
   the history appear as follows:

   ```console
   $ git log --oneline --graph
   * 056d8a4 (HEAD -> main) Revert "Nineth commit"
   * 24f4de7 (learngit1) Seventh commit
   * 36404de Eighth commit
   * a17a661 Nineth commit
   * c7aa82d (origin/main) Sixth.txt commit
   ...
   ...

   $ ls Nineth.txt
   ls: Nineth.txt: No such file or directory
   ```

6. Reverting the commits can be achieved by using `git reset --hard HEAD~1`
   multiple times until we reach `Sixth commit`, or by passing the specific
   commit id of `Sixth commit`.

   In both cases the history and the status of the repo will be moved to that
   specific moment.

   Given this list:

   ```console
   $ git log --oneline --graph
   * 056d8a4 (HEAD -> main) Revert "Nineth commit"
   * 24f4de7 (learngit1) Seventh commit
   * 36404de Eighth commit
   * a17a661 Nineth commit
   * c7aa82d (origin/main) Sixth.txt commit
   ...
   ...
   ```

   We want to move back to `c7aa82d`, So the command will be:

   ```console
   git reset --hard c7aa82d
   HEAD is now at c7aa82d Sixth.txt commit
   ```

   The history will now be:

   ```console
   $ git log --oneline --graph
   * c7aa82d (HEAD -> main, origin/main) Sixth.txt commit
   ...
   ...
   ```

   Now `HEAD` is `c7aa82d`. Remember that without `--hard` the working directory
   would have still the `txt` files coming form the commits.

7. To reconstruct an ordinated history `git cherry-pick` can be used to pick
   commits from the `learngit1` branch in the correct order, like in:

   ```console
   $ git log --oneline --graph learngit1
   * 24f4de7 (learngit1) Seventh commit
   * 36404de Eighth commit
   * a17a661 Nineth commit
   * c7aa82d (HEAD -> main, origin/main) Sixth.txt commit
   * 7cb2eb8 (mynewfeature) Sixth.txt mynewfeature commit

   $ git branch
     learngit1
   * main
     myfeature
     mynewfeature

   $ git cherry-pick 24f4de7
   [main 33ccdb9] Seventh commit
    Date: Fri Mar 8 14:28:54 2024 +0000
    1 file changed, 1 insertion(+)
    create mode 100644 Seventh.txt

   $ git cherry-pick 36404de
   [main 34cf4dd] Eighth commit
    Date: Fri Mar 8 14:28:54 2024 +0000
    1 file changed, 1 insertion(+)
    create mode 100644 Eighth.txt

   $ git cherry-pick a17a661
   [main 525b121] Nineth commit
    Date: Fri Mar 8 14:28:54 2024 +0000
    1 file changed, 1 insertion(+)
    create mode 100644 Nineth.txt
   ```

   Commit history will now be correctly ordered:

   ```console
   $ git log --oneline --graph
   * 525b121 (HEAD -> main) Nineth commit
   * 34cf4dd Eighth commit
   * 33ccdb9 Seventh commit
   * c7aa82d (origin/main) Sixth.txt commit
   ```

   And we can also align our remote:

   ```console
   $ git push
   Enumerating objects: 10, done.
   Counting objects: 100% (10/10), done.
   Delta compression using up to 16 threads
   Compressing objects: 100% (6/6), done.
   Writing objects: 100% (9/9), 883 bytes | 883.00 KiB/s, done.
   Total 9 (delta 3), reused 0 (delta 0), pack-reused 0
   To /git/myrepo-bare/
      c7aa82d..525b121  main -> main

   $ git log --oneline --graph
   * 525b121 (HEAD -> main, origin/main) Nineth commit
   * 34cf4dd Eighth commit
   * 33ccdb9 Seventh commit
   * c7aa82d Sixth.txt commit
   ```
