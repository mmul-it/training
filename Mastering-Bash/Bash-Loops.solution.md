# Exercise | Declare, initialize and print every element of an array | Solution

1. Suppose your user is `kirater` and your machine is `machine`:

   ```console
   > ssh kirater@machine
   ```

2-8. The script should be something like this:

     ```bash
     #/bin/bash
     
     # 3) Array initialization
     declare -a tarantino
     
     tarantino=(
         'Reservoir Dogs'
         'Pulp Fiction'
         'Kill Bill'
         'Inglourious Basterds'
         'Django Unchained'
     )
     
     echo "${tarantino[@]}"
     
     # 4) One element per line
     for title in "${tarantino[@]}"
     do
         echo "$title"
     done 
     
     # 5) The same with sort
     for title in "${tarantino[@]}"
     do
         echo "$title"
     done | sort
     
     # 6) Delete an element
     unset tarantino[3]
     
     # 7) Print the indexes
     for index in "${!tarantino[@]}"
     do
         echo "$index"
     done
     
     # 8) Pretty print of the array contents
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
