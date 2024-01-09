# Lab | Declare, initialize and print every element of an array

In this lab you will:

1. Write a script that will declare the array `$tarantino`;
2. Initialize `$tarantino` with the following values:

   - `Reservoir Dogs`
   - `Pulp Fiction`
   - `Kill Bill`
   - `Inglourious Basterds`
   - `Django Unchained`

   Remember to quote strings to preserve spaces.
3. Print all the values of `$tarantino`, one per line, remembering to quote the
   variable `${tarantino[@]}` in the `for` loop.
4. Sort the output with `sort`.
5. Unset element with index `3`.
6. Print all the indexes of `$tarantino`, one per line.
7. Print all the elements of $tarantino with index, one per line:
   `<index>) <element>`.

## Solution

1. ->
2. ->
3. ->
4. ->
5. ->
6. ->
7. The script should be something like this:

   ```bash
   #/bin/bash

   # 2. Array initialization
   declare -a tarantino

   tarantino=(
       'Reservoir Dogs'
       'Pulp Fiction'
       'Kill Bill'
       'Inglourious Basterds'
       'Django Unchained'
   )

   echo "${tarantino[@]}"

   # 3. One element per line
   for title in "${tarantino[@]}"
   do
       echo "$title"
   done

   # 4. The same with sort
   for title in "${tarantino[@]}"
   do
       echo "$title"
   done | sort

   # 5. Delete an element
   unset tarantino[3]

   # 6. Print the indexes
   for index in "${!tarantino[@]}"
   do
       echo "$index"
   done

   # 7. Pretty print of the array contents
   for index in "${!tarantino[@]}"
   do
       echo "$index) ${tarantino[$index]}"
   done
   ```

   **NOTE**: declaration (with 'declare -a') are made in two different points, that
   in a (much) more complicated script could be very far.
   The initialization could be on a single line:

   ```bash
   tarantino=( 'Reservoir Dogs' 'Pulp Fiction' 'Kill Bill' 'Inglourious Basterds' 'Django Unchained' )
   ```

   but one line per item is often more readeable.

   **NOTE**: the quoted list in `${tarantino[@]}` that will preserve the spaces for
   the strings in the array.
