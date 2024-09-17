# Lab | Learn how to use multiple remotes into one repository

In this lab you will:

1. Use the `myrepo` repository as the working directory, and the previously
   created `myrepo-bare` as a remote.
2. Configure `myrepo-bare` as the `origin` remote for `myrepo`.
3. Push all the contents of `myrepo` into `myrepo-bare`.
4. Create a new repository named `myotherrepo`, configure `myrepo-bare` as
   `origin`, pull its contents and verify that now we have the entire set of
   modifications coming from `myrepo`.
5. Use `git fetch` to make additional remote branches available to the local
   repository.

## Solution

1. Repository should be available in the `myrepo` folder. To use it as a workdir
   just use `cd`:

   ```console
   ~ $ cd myrepo
   (no output)

   ~/myrepo $ git status
   On branch main
   nothing to commit, working tree clean

   ~/myrepo $ cd ../myrepo-bare/

   ~/myrepo-bare $ git status
   fatal: this operation must be run in a work tree
   ```

   Since `myrepo-bare` is not a work tree the message is expected.

2. To make the bare repo the `origin` for `myrepo` we will use `git remote add`:

   ```console
   ~/myrepo-bare $ cd ../myrepo

   ~/myrepo $ git remote add origin /git/myrepo-bare/

   ~/myrepo $ git remote
   origin

   ~/myrepo $ git remote -v
   origin     /git/myrepo-bare/ (fetch)
   origin     /git/myrepo-bare/ (push)
   ```

3. Now to push everything on the remote, let's use `git push`:

   ```console
   ~/myrepo $ git push
   fatal: The current branch main has no upstream branch.
   To push the current branch and set the remote as upstream, use

       git push --set-upstream origin main

   To have this happen automatically for branches without a tracking
   upstream, see 'push.autoSetupRemote' in 'git help config'.
   ```

   The message shows where is the problem, `git` don't know where to push.
   A solution could be to use the suggested commaand:

   ```console
   ~/myrepo $ git push --set-upstream origin main
   Enumerating objects: 24, done.
   Counting objects: 100% (24/24), done.
   Delta compression using up to 16 threads
   Compressing objects: 100% (18/18), done.
   Writing objects: 100% (24/24), 2.07 KiB | 353.00 KiB/s, done.
   Total 24 (delta 8), reused 0 (delta 0), pack-reused 0
   To /git/myrepo-bare/
    * [new branch]      main -> main
   branch 'main' set up to track 'origin/main'.
   ```

   From now on there'll be no need to pass again `--set-upstream origin main`.

   It is also possible to pass the `--all` option, to load **all** the additional
   branches (in this case `myfeature`):

   ```console
   ~/myrepo $ git push --all
   Total 0 (delta 0), reused 0 (delta 0), pack-reused 0
   To /git/myrepo-bare/
    * [new branch]      myfeature -> myfeature
   ```

4. The creation of the new repository with the relative remote will follow the
   usual process:

   ```console
   ~/myrepo $ cd ..
   (no output)

   ~ $ mkdir -v myotherrepo
   created directory: 'myotherrepo'

   ~ $ cd myotherrepo/
   (no output)

   ~/myotherrepo $ git init --initial-branch=main
   Initialized empty Git repository in /git/myotherrepo/.git/

   ~/myotherrepo $ git remote add origin /git/myrepo-bare/
   (no output)
   ```

   As before we need to indicate to `git` which upstream are we relying on, in
   this case `main`, coming from `origin`:

   ```console
   ~/myotherrepo $ git pull origin main
   remote: Enumerating objects: 24, done.
   remote: Counting objects: 100% (24/24), done.
   remote: Compressing objects: 100% (18/18), done.
   remote: Total 24 (delta 8), reused 0 (delta 0), pack-reused 0
   Unpacking objects: 100% (24/24), 2.05 KiB | 526.00 KiB/s, done.
   From /git/myrepo-bare
    * branch            main       -> FETCH_HEAD
    * [new branch]      main       -> origin/main
   ```

   The repository is now a perfectly working directory:

   ```console
   ~/myotherrepo $ git log --oneline --graph
   *   38fceae (HEAD -> main, origin/main) Merge branch 'myfeature'
   |\
   | * 7f002cd Fifith.txt myfeature commit
   * | 408ed5d Fifth.txt commit
   |/
   * acce6eb Fourth.txt commit
   * d523228 Adding .gitignore
   * cb10f6d Third commit
   * ecef636 Second commit
   * 7966140 First commit
   ```

5. In terms of branches we don't have at the moment anything apart from `main`:

   ```console
   ~/myotherrepo $ git branch
   * main
   ```

   To make the repository aware of the remote branches and their commits we can
   rely on `git fetch` as follows:

   ```console
   ~/myotherrepo $ git fetch --all
   From /git/myrepo-bare
    * [new branch]      myfeature  -> origin/myfeature
   ```

   Note that it is wise to launch the fetch command everytime you expect some
   remotes modifications, because otherwise new changes coming from the remote
   will not be available locally.
