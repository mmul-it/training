# Lab | Enable Git completion

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Create two files in the `documentation/files` folder:
   - `a-long-name-for-a-file.txt`
   - `a-file.txt`
   and commit them.
3. Install and configure Git completion and make use of it from now on.
4. Create a branch named `dev/the-longest-branch-name-you-ever-seen`.
5. Helped by auto completion Switch to the `dev/the-longest-branch-name-you-ever-seen`
   branch modify documentation files and commit.
6. Back to `main` branch change the `dev/the-longest-branch-name-you-ever-seen`
   branch name in `dev/T-34-bugfix`.

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

2. Create directories and files to commit:

   ```console
   ~/myrepo $ mkdir -vp documentation/files
   created directory: 'documentation/'
   created directory: 'documentation/files'

   ~/myrepo $ touch documentation/files/a-long-name-for-a-file.txt documentation/files/a-file.txt
   (no output)

   ~/myrepo $ git add .
   (no output)

   ~/myrepo $ git commit -m "Sample log documentation commit" -m "This commit contains very logn paths."
   [main 209c809] Sample log documentation commit
    2 files changed, 0 insertions(+), 0 deletions(-)
    create mode 100644 documentation/files/a-file.txt
    create mode 100644 documentation/files/a-long-name-for-a-file.txt
   ```

   Without auto completion it takes a lot to manage long file names and paths.

3. Configure Git completion depending on your Linux distribution.

   On RHEL based systems:

   ```console
   ~/myrepo $ sudo yum -y install bash-completion
   ...
   ```

   On Debian based systems:

   ```console
   ~/myrepo $ sudo apt update && apt install -y bash-completion
   ```

   To activate it and make it loaded on every bash terminal login:

   ```console
   ~/myrepo $ echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc
   (no output)

   ~/myrepo $ source ~/.bashrc
   (no output)
   ```

4. Create the `dev/the-longest-branch-name-you-ever-seen` branch:

   ```console
   ~/myrepo $ git checkout -b dev/the-longest-branch-name-you-ever-seen
   Switched to a new branch 'dev/the-longest-branch-name-you-ever-seen'
   ```

5. Change a file content with the help of the completion:

   ```console
   ~/myrepo $ echo "Bug fix documentation about Jira Ticket n. 34" >> documentation/files/a-long-name-for-a-file.txt
   (no output)
   ```

   Add the file to staged commit by pressing tab three times to complete the
   entire file path:

   ```console
   ~/myrepo $ git add <TAB>
   ~/myrepo $ git add documentation/<TAB>
   ~/myrepo $ git add documentation/files/<TAB>
   ~/myrepo $ git add documentation/files/a-long-name-for-a-file.txt
   (no output)

   ~/myrepo $ git status
   On branch dev/the-longest-branch-name-you-ever-seen
   Changes to be committed:
     (use "git restore --staged <file>..." to unstage)
        modified:   documentation/files/a-long-name-for-a-file.txt

   ~/myrepo $ git commit -m "[feat] Fixing documentation" -m "This is a test for git completion."
   [dev/the-longest-branch-name-you-ever-seen 2de2611] [feat] Fixing documentation
    1 file changed, 1 insertion(+)
   ```

6. Change the `dev/the-longest-branch-name-you-ever-seen` branch name in
   `dev/T-34-bugfix` using auto-complete:

   ```console
   ~/myrepo $ git checkout main
   Switched to branch 'main'

   ~/myrepo $ git branch -m d<TAB>
   ~/myrepo $ git branch -m dev/the-longest-branch-name-you-ever-seen dev/T-34-bugfix
   (no output)

   ~/myrepo $ git branch
     dev/T-34-bugfix
   * main
   ```
