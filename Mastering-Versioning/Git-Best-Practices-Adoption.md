# Lab | Apply Git Best Practices to a repository

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Check that a Git hook that accepts only commits that have a commit message
   starting with `feat:` or `fix:` is present.
3. Avoid any kind of sensitive SSH keys, so for both `id_rsa` and `id_rsa.pub`
   files.
4. Enable Git LFS (_Large File Storage_) to manage `.zip` files in a dedicated
   place and verify their placement by creating a 10MB sample zip file.
5. Check the hooks and that ssh keys are not tracked.

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

2. As seen in [Git-Hooks.md](Git-Hooks.md) the Git hook will be a script, that
   detects if the commit message starts with `feat:` or `fix:`, throwing an
   error and preventing from committing if requirements are not met.

   The `commit-msg` Git hook will be:

   ```console
   ~/myrepo $ cat <<EOF > .git/hooks/commit-msg
   grep -q '^feat: \|^bug: ' \$1 &> /dev/null
   if [ \$? -ne 0 ]
    then
     echo "[ERROR] Commit must start with 'feat:' or 'bug:'!"
     exit 1
   fi
   EOF
   ```

   And must be executable:

   ```console
   ~/myrepo $ chmod -v +x .git/hooks/commit-msg
   mode of '.git/hooks/commit-msg' changed to 0755 (rwxr-xr-x)
   ```

3. Removing SSH keys from tracking is just a matter of adding `id_rsa*` into
   `.gitignore` and commit the modification:

   ```console
   ~/myrepo $ echo 'id_rsa*' >> .gitignore

   ~/myrepo $ git add .gitignore && git commit -m "feat: ignore id_rsa key files" -m "This applies the best practice to exclude SSH private and public keys."
   [main 978602b] feat: ignore id_rsa key files
    1 file changed, 1 insertion(+)
   ```

4. Git LFS is supported by a system if the `git-lfs` package is installed. This
   can be done on RHEL based systems with:

   ```console
   $ sudo yum -y install git-lfs
   ...
   ```

   And on Debian based systems with:

   ```console
   $ sudo apt -y install git-lfs
   ...
   ```

   Then Git LFS can be enabled with the `git lfs install` command:

   ```console
   ~/myrepo $ git lfs install
   Updated Git hooks.
   Git LFS initialized.
   ```

   Then to track the `*.zip` files `git lfs track` should be used as follows:

   ```console
   ~/myrepo $ git lfs track "*.zip"
   Tracking "*.zip"
   ```

   This will create `.gitattributes`:

   ```console
   ~/myrepo $ cat .gitattributes
   *.zip filter=lfs diff=lfs merge=lfs -text
   ```

   And a commit will add it to the repo:

   ```console
   ~/myrepo $  git add .gitattributes && git commit -m "Enable LFS for zip files" -m "This is made to avoid large files to be stored in the repo"
   [main 308e38d] Enable LFS for zip files
    1 file changed, 1 insertion(+)
    create mode 100644 .gitattributes
   ```

   Now to check that everything is working, add a 10MB file sample:

   ```console
   ~/myrepo $ dd if=/dev/zero of=myarchive.zip bs=1024 count=10000
   10000+0 records in
   10000+0 records out
   10240000 bytes (9.8MB) copied, 0.058306 seconds, 167.5MB/s

   ~/myrepo $ du -sh myarchive.zip
   9.8M    myarchive.zip
   ```

   And check the actual size of the `.git` directory:

   ```console
   ~/myrepo $ du -sh .git
   864.0K    .git
   ```

   Now, in normal conditions a commit for the `myarchive.zip` would add
   the commit object under `.git/objects/`, but since we're using LFS,
   the path where the object is stored is different:

   ```console
   ~/myrepo $ find .git -size +50
   .git/lfs/objects/31/e0/31e00e0e4c233c89051cd748122fde2c98db0121ca09ba93a3820817ea037bc5
   ```

   So `.git/lfs` is tracked elsewhere, and so it will be during the push.

5. To test the `commit-msg` Git hook:

   ```console
   ~/myrepo $ echo "A test for the commit-msg hook" >> First.txt
   (no output)

   ~/myrepo $ git add First.txt
   (no output)

   ~/myrepo $ git commit -m "Test commit-msg hook" -m "Extended description of the commit"
   [ERROR] Commit must start with 'feat:' or 'bug:'!
   ```

   And to test the `id_rsa` file exclusion first create a SSH keypair inside
   `myrepo`:

   ```console
   ~/myrepo $ ssh-keygen -f ./id_rsa
   Generating public/private ed25519 key pair.
   Enter passphrase (empty for no passphrase):
   Enter same passphrase again:
   Your identification has been saved in ./id_rsa
   Your public key has been saved in ./id_rsa.pub
   The key fingerprint is:
   SHA256:WRqX10yZBlJducZlwACaXscUenK+Z8sOQ2BumytgXIM git@e7cfabef57c4
   The key's randomart image is:
   +--[ED25519 256]--+
   |          oo**o=o|
   |         o * +*.o|
   |       .+ X *.+.o|
   |      E.oX O   + |
   |     . .S.o o .  |
   |      +  . + .   |
   |     . .  o + o  |
   |        .  . * . |
   |         ..  .+  |
   +----[SHA256]-----+
   ```

   If `.gitignore` was correctly populated the `git status` command should
   return a list that is excluding `id_rsa*` files:

   ```console
   ~/myrepo $ git status
   On branch main
   Your branch is up to date with 'origin/main'.

   Changes to be committed:
     (use "git restore --staged <file>..." to unstage)
        modified:   First.txt

   ```

   The `First.txt` file is mentioned because it was not committed due to the
   hook preventing it, and since we don't care, we can safely `checkout` it:

   ```console
   ~/myrepo $ git reset && git checkout First.txt
   Unstaged changes after reset:
   M     First.txt
   Updated 1 path from the index

   ~/myrepo $ git status
   On branch main
   Your branch is up to date with 'origin/main'.

   nothing to commit, working tree clean
   ```

   The repo is clean again.
