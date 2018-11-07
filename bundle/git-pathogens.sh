#!/bin/bash

# get current directory of script, see https://stackoverflow.com/a/246128
CURRENTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# dump each line of plugins.txt into an array
arr=()
while IFS= read -r line && [[ "$line" ]]; do
  arr+=("$line")
done < plugins.txt

# for each plugin in $arr, clone it into current directory
arr_len=${#arr[@]}
for i in "${!arr[@]}"; do
  # if $plugin is "markonm/traces.vim"
  plugin=${arr[$i]}
  # then $name is "traces.vim"
  name="$( echo $plugin | sed -n 's:[^/]*/\([^/]*\).*:\1:p' )"
  # if directory already exists, delete it so we can clone without conflict
  if [[ ! -z "${name// /}" && -d "$CURRENTDIR/$name" ]]; then
    rm -rf "$CURRENTDIR/$name"
  fi
  echo "----------------------------------------"
  echo "[$(($i + 1))/$arr_len] $plugin"
  git clone "https://github.com/$plugin"
done

# remove all .git dirs from the cloned plugins
find $CURRENTDIR | sed -n 's:\(.*/\.git/\)HEAD:\1:p' | xargs rm -rf
