# Exercise | Substitutions with sed

Use the file `results.txt` from the [Bash-Outputs.md](Bash-Outputs.md) exercise.

1. Substitute first match of `root` with `love`.
2. Substitute every match of `root` with `love` (remember the option `g`).
3. Substitute every digit with a dot (remember range).
4. Substitute every number with a single dot (remember escape in pattern).
5. Substitute every number with a single dot, then remove the pattern `:.`. 
   (substitute with empty string).
6. Substitute until the `:` with the string `<s_user>` if line begins with `s`.
