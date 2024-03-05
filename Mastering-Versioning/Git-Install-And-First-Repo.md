# Lab | Install Git and create a repository

In this lab you will:

1. Install `git` environment in your system.
2. Create a standard Git repository in a folder named `myrepo`.
3. Check the `.git` directory structure.
4. Create a Git **bare** reporitory in a folder named `myrepo-bare`.
5. Compare the new repository directory structure with the previous one.

## Solution

1. Git can be installed following the [official instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
   Depending on the used Linux distribution you might need to use `dnf` (on RHEL
   based systems):

   ```console
   $ sudo dnf install git-all
   ...
   ```

   or `apt` (on Debian based systems):

   ```console
   $ sudo apt install git-all
   ...
   ```

2. After this a standard repository can be initialized, by using `git init`
   with the main branch specification, as in `-b main`:

   ```console
   $ mkdir -v myrepo
   mkdir: created directory 'myrepo'

   $ cd myrepo
   (no output)

   $ git init --initial-branch main
   Initialized empty Git repository in /git/myrepo/.git/
   ```

3. To check the structure use `tree`

   ```console
   $ tree -a
   .
   └── .git
       ├── branches
       ├── config
       ├── description
       ├── HEAD
       ├── hooks
       │   ├── applypatch-msg.sample
       │   ├── commit-msg.sample
       │   ├── post-update.sample
       │   ├── pre-applypatch.sample
       │   ├── pre-commit.sample
       │   ├── pre-merge-commit.sample
       │   ├── prepare-commit-msg.sample
       │   ├── pre-push.sample
       │   ├── pre-rebase.sample
       │   ├── pre-receive.sample
       │   ├── push-to-checkout.sample
       │   ├── sendemail-validate.sample
       │   └── update.sample
       ├── info
       │   └── exclude
       ├── objects
       │   ├── info
       │   └── pack
       └── refs
           ├── heads
           └── tags

   10 directories, 17 files
   ```

4. To create a bare repository the `--bare` option is needed:

   ```console
   $ mkdir -v myrepo-bare
   mkdir: created directory 'myrepo'

   $ cd myrepo-bare/
   (no output)

   $ git init --bare --initial-branch main
   Initialized empty Git repository in /git/myrepo-bare/
   ```

5. Checking again the directory structure will show the differences:

   ```console
   $ tree -a
   .
   ├── HEAD
   ├── branches
   ├── config
   ├── description
   ├── hooks
   │   ├── applypatch-msg.sample
   │   ├── commit-msg.sample
   │   ├── post-update.sample
   │   ├── pre-applypatch.sample
   │   ├── pre-commit.sample
   │   ├── pre-merge-commit.sample
   │   ├── pre-push.sample
   │   ├── pre-rebase.sample
   │   ├── pre-receive.sample
   │   ├── prepare-commit-msg.sample
   │   ├── push-to-checkout.sample
   │   ├── sendemail-validate.sample
   │   └── update.sample
   ├── info
   │   └── exclude
   ├── objects
   │   ├── info
   │   └── pack
   └── refs
       ├── heads
       └── tags

   9 directories, 17 files
   ```

   Files and folders are created directly into the the repository folder,
   which is not meant to contain any workable file.
