# Lab | Implement and test the pre commit Git hook

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Inspect the `.git/hooks` folder, activate the `pre-commit` Git
   hook, and test it.
3. Disable the `pre-commit` hook.
4. Write a Git hook that accepts only commits that have a commit message
   starting with `feat:` or `fix:`.
5. Test the newly created Git hook.
6. Perform the commit skipping the Git hook execution.
7. Remove the hook.

## Solution

1. Repository should be available in the `myrepo` folder. To use it as a workdir
   just use `cd`:

   ```console
   ~ $ cd myrepo
   (no output)

   ~/myrepo $ git status
   On branch main
   Your branch is up to date with 'origin/main'.

   nothing to commit, working tree clean
   ```

2. The `.git/hooks` folder is populated my `.sample` files:

   ```console
   ~/myrepo $ ls -1 .git/hooks
   applypatch-msg.sample
   commit-msg.sample
   fsmonitor-watchman.sample
   post-update.sample
   pre-applypatch.sample
   pre-commit.sample
   pre-merge-commit.sample
   pre-push.sample
   pre-rebase.sample
   pre-receive.sample
   prepare-commit-msg.sample
   push-to-checkout.sample
   update.sample
   ```

   To activate the `pre-commit` Git hook it will be sufficient to rename the
   `pre-commit.sample` into `pre-commit`:

   ```console
   ~/myrepo $ mv -v .git/hooks/pre-commit.sample .git/hooks/pre-commit
   '.git/hooks/pre-commit.sample' -> '.git/hooks/pre-commit'
   ```

   By default, the pre-commit hook will check also for trailing white spaces,
   so to verify it is working let's create a sample commit with a trailing
   space:

   ```console
   $ echo "A line with a trailing whitespace " >> First.txt
   (no output)

   $ git add First.txt
   (no output)

   $ git commit -m "Trying to commit a file with a trailing whitespace"
   First.txt:2: trailing whitespace.
   +A line with a trailing whitespace
   ```

   The commit is not permitted, because of the hook.

3. Reset the file and disable the `pre-commit` script by moving it back:

   ```console
   ~/myrepo $ git reset First.txt
   Unstaged changes after reset:
   M     First.txt

   ~/myrepo $ git checkout First.txt
   Updated 1 path from the index

   ~/myrepo $ mv -v .git/hooks/pre-commit .git/hooks/pre-commit.sample
   '.git/hooks/pre-commit' -> '.git/hooks/pre-commit.sample'
   ```

4. Since a Git hook is essentially a script, let's create a bash script that
   detects if the commit message starts with `feat:` or `fix:`, throwing an
   error and preventing from committing if requirements are not met.

   In order to do that we make use of the `commit-msg` Git hook:

   ```console
   ~/myrepo $ cat <<EOF > .git/hooks/commit-msg
   grep -q '^feat: \|^bug: ' \$1 &> /dev/null
   if [ \$? -ne 0 ]
    then
     echo "[ERROR] Commit must start with 'feat:' or 'bug:!'"
     exit 1
   fi
   EOF
   ```

   And make it executable:

   ```console
   ~/myrepo $ chmod -v +x .git/hooks/commit-msg
   mode of '.git/hooks/commit-msg' changed to 0755 (rwxr-xr-x)
   ```

5. Test the newly created `commit-msg` Git hook:

   ```console
   ~/myrepo $ echo "A test for the commit-msg hook" >> First.txt
   (no output)

   ~/myrepo $ git add First.txt
   (no output)

   ~/myrepo $ git commit -m "Test commit-msg hook" -m "Extended description of the commit"
   [ERROR] Commit must start with 'feat:' or 'bug:!'
   ```

6. To commit in any case, skipping the Git hook execution, the `--no-verify`
   option must be passed:

   ```console
   ~/myrepo $ git commit --no-verify -m "Test commit-msg hook bypass" -m "This is a sample commit to bypass the commit-msg"
   [main 451c30c] Test commit-msg hook bypass
    1 file changed, 1 insertion(+)

   ~/myrepo $ git log --oneline --graph
   * 451c30c (HEAD -> main) Test commit-msg hook bypass
   * 525b121 (origin/main) Nineth commit
   ...
   ...
   ```

7. To remove the hook it will be sufficient to remove `.git/hooks/commit-msg`:

   ```console
   $ rm -v .git/hooks/commit-msg
   removed '.git/hooks/commit-msg'
   ```
