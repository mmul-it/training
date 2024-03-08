# Lab | Git hooks

In this lab you will:

1. Initialize a Git repository and perform an initial commit.
2. Inspect the `.git/hooks` folder, activate the `pre-commit` Git
   hook, and test it.
3. Disable the `pre-commit` hook.
4. Your organization adopts conventional commits, write a Git hook that accepts
   only commits that have a commit message starting with `feat:` or `fix:`.
5. Test the newly created Git hook.
6. Perform a commit skipping the Git hook execution.
7. Delete the repository.

## Solution

1. Initialize a Git repository and perform an initial commit:

   ```console
   $ git init repo && cd repo
   Initialized empty Git repository in /home/repo/.git/
   $ touch example_file
   (no output)
   $ git add example_file
   (no output)
   $ git commit -m "Initial commit"
   [master (root-commit) 46dc6d4] Initial commit
    1 file changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 example_file
   ```

2. Inspect the `.git/hooks` folder, activate the `pre-commit` Git
   hook, and test it:

   ```console
   $ ls -1 .git/hooks
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
   $ mv .git/hooks/pre-commit.sample .git/hooks/pre-commit
   (no output)
   $ echo "A line with a trailing whitespace " > example_file
   (no output)
   $ git add example_file
   (no output)
   $ git commit -m "Trying to commit a file with a trailing whitespace"
   example_file:1: trailing whitespace.
   +A line with a trailing whitespace
   $ git log
   commit 46dc6d493a96718a2a5547de3048b1f8a61233ab (HEAD -> master)
   Author: Your Name <you@example.com>
   Date:   Tue Mar 5 17:24:10 2024 +0000

       Initial commit
   ```

3. Disable the `pre-commit` script:

   ```console
   mv .git/hooks/pre-commit .git/hooks/pre-commit.sample
   ```

4. Create a bash script to detect if the commit message starts with
   `feat:` or `fix:`, throwing an error and preventing from committing if
   requirements are not met. In order to do that we make use of the
   `commit-msg` Git hook:

   ```console
   $ ERR_MEX='[ERROR] Conventional commits policy is not met!'
   (no output)
   $ echo "grep -q '^feat: \|^bug: ' \$1 || { echo >&2 $ERR_MEX; exit 1; }" > .git/hooks/commit-msg.sample
   (no output)
   $ mv .git/hooks/commit-msg.sample .git/hooks/commit-msg
   (no output)
   ```

5. Test the newly created `commit-msg` Git hook:

   ```console
   $ echo "Adding a new line" >> example_file && git add example_file
   (no output)
   $ git commit -m "Second commit"
   [ERROR] Conventional commits policy is not met!
   $ git log
   commit 46dc6d493a96718a2a5547de3048b1f8a61233ab (HEAD -> master)
   Author: Your Name <you@example.com>
   Date:   Tue Mar 5 17:24:10 2024 +0000

       Initial commit
   $ git commit -m "feat: Adding a new line"
   [master f28d768] feat: Adding a new line
    1 file changed, 2 insertions(+)
   ```

6. Perform a commit skipping the Git hook execution:

   ```console
   $ echo "Adding the third line" >> example_file && git add example_file
   (no output)
   $ git commit --no-verify -m "Third commit"
   [master 0f55c5d] Third commit
    1 file changed, 1 insertion(+)
   $ git shortlog
   Your Name (3):
         Initial commit
         feat: Adding a new line
         Third commit
   ```

7. Delete the repository:

   ```console
   $ cd .. && rm -r repo
   (no output)
   ```
