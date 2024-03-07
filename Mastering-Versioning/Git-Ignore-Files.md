# Lab | Play between tracked and ignored files.

In this lab you will:

1. Use the `myrepo` repository as the working directory.
2. Create three sample files:
   | File name      | Content                           |
   |----------------|-----------------------------------|
   | `Password.txt` | `mypassword`                      |
   | `Fourth.txt`   | `Contents of the Fourth file.`    |
   | `cache.tmp`    | `This file should not be tracked` |
   `Branch myfeature modification for the Fourth.txt commit.`.
3. Check with `git status` which files will be staged.
4. Create a `.gitignore` file to make git ignore these files:
   - `*.tmp`
   - `Password.txt`
5. Check again with `git status` which files will now be staged.
6. Create two separate commits, one for `.gitignore` and one for the `Fourth.txt`
   file with the message `Fourth.txt commit`.

## Solution

1. Repository should be available in the `myrepo` folder. To use it as a workdir
   just use `cd`:

   ```console
   ~/myrepo $ cd myrepo
   (no output)

   ~/myrepo $ git status
   On branch main
   nothing to commit, working tree clean
   ```

2. The three files can be populated in this way:

   ```console
   ~/myrepo $ echo mypassword > Password.txt

   ~/myrepo $ echo "Contents of the Fourth file." > Fourth.txt

   ~/myrepo $ echo "This file should not be tracked" > cache.tmp
   ```

3. The status of the repo is:

   ```console
   ~/myrepo $ git status
   On branch main
   Untracked files:
     (use "git add <file>..." to include in what will be committed)
        Fourth.txt
        Password.txt
        cache.tmp

   nothing added to commit but untracked files present (use "git add" to track)
   ```

   As we can see, all the three files are seen as `Untracked`, and this means
   that git "sees" them.

4. The `.gitignore` is a simple text file, with each line representing a
   specific file or a group of files that relies on wildcards:

   ```console
   ~/myrepo $ echo -e '*.tmp\nPassword.txt' > .gitignore

   ~/myrepo $ cat .gitignore
   *.tmp
   Password.txt
   ```

5. With `.gitignore` in place the status of the repo will change:

   ```console
   ~/myrepo $ git status
   On branch main
   Untracked files:
     (use "git add <file>..." to include in what will be committed)
        .gitignore
        Fourth.txt

   nothing added to commit but untracked files present (use "git add" to track)
   ```

   Just two files are tracked: `Fourth.txt` and the newly created `.gitignore`.

6. As a best practice it is better to separate in two distinct commits the two
   files, one dedicated to the ignore part and the other with the effective
   file:

   ```console
   ~/myrepo $ git add .gitignore
   (no output)

   ~/myrepo $ git commit -m "Adding .gitignore" -m "This commit is kept alone from the rest."
   [main d523228] Adding .gitignore
    1 file changed, 2 insertions(+)
    create mode 100644 .gitignore

   ~/myrepo $ git add Fourth.txt
   (no output)

   ~/myrepo $ git commit -m "Fourth.txt commit" -m "This is the description of the Fourth commit."
   [main acce6eb] Fourth.txt commit
    1 file changed, 1 insertion(+)
    create mode 100644 Fourth.txt

   ~/myrepo $ git log --oneline --graph 
   * acce6eb (HEAD -> main) Fourth.txt commit
   * d523228 Adding .gitignore
   * cb10f6d Third commit
   * ecef636 Second commit
   * 7966140 First commit
   ```
