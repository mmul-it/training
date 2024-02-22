# Lab | Git Completion

In this lab you will:

1. Initialize a Git repository.
2. Create two files named `a-long-name-for-a-file.txt` and `a-file.txt` in the folder `contents/files` and commit them.
3. Create a branch named `dev/the-longest-branch-name-you-ever-seen`, modify a file and commit it.
4. Install / Configure Git completion and make use of it from now on.
5. Switch to the main branch, modify the previous created file and commit.
6. Change the `dev/the-longest-branch-name-you-ever-seen` branch name in `dev/T-34-bugfix`.
7. Delete the repository.

## Solution

1. Initialize a Git repository:

   ```console
   $ mkdir repo && cd repo
   $ git init
   ...
   Initialized empty Git repository in /home/repo/.git
   ```

2. Create directories and a file to commit:

   ```console
   $ mkdir -p contents/files
   $ touch contents/files/a-long-name-for-a-file.txt contents/files/a-file.txt
   $ git add .
   $ git commit -m "Initial commit"
   [master (root-commit) 9708685] Initial commit
   2 files changed, 0 insertions(+), 0 deletions(-)
   create mode 100644 contents/files/a-file.txt
   create mode 100644 contents/files/a-long-name-for-a-file.txt
   ```

3. Modify a file in a different branch, `dev/the-longest-branch-name-you-ever-seen`, and commit it:

   ```console
   $ git checkout -b dev/the-longest-branch-name-you-ever-seen
   $ echo "Bug fix documentation about Jira Ticket n. 34" >> contents/files/a-long-name-for-a-file.txt
   $ git add contents/files/a-long-name-for-a-file.txt
   $ git status
   On branch dev/the-longest-branch-name-you-ever-seen
   Changes to be committed:
   (use "git restore --staged <file>..." to unstage)
      modified:   contents/files/a-long-name-for-a-file.txt
   $ git commit -m "[feat] Adding documentation"
   ```

4. Configure Git completion:

   ```console
   echo "source /usr/share/bash-completion/completions/git" >> ~/.bashrc
   source ~/.bashrc
   ```

5. Modify and commit a file on the main branch using auto-complete:

   ```console
   $ git branch --all
   * dev/the-longest-branch-name-you-ever-seen
   master
   $ git checkout master
   $ echo "Changed" >> contents/files/a-file.txt
   $ git add contents/files/a-file.txt
   $ git commit -m "Changing a file"
   ```

6. Change the `dev/the-longest-branch-name-you-ever-seen` branch name in `dev/T-34-bugfix` using auto-complete:

   ```console
   $ git branch -m dev/the-longest-branch-name-you-ever-seen dev/T-34-bugfix
   $ git branch --all
   * master
   dev/T-34-bugfix
   ```

7. Delete the repository:

   ```console
   cd .. && rm -r repo
   ```
