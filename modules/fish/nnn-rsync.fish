set --function paths
set --function extra_args
set --function tmp $(mktemp)

if test ! $argv[1]
  echo "Destination required"
  return 1
end

nnn -p $tmp || return 1

if test ! -f $tmp
  echo "No files or directories were selected"
  return 1
end

for path in $(cat $tmp)
  if test ! -e $path
    echo "$path does not exist"
    return 1
  end
  set --append paths $(string replace --regex '/+$' '' $path | string escape)
end

for arg in $argv
  set --append extra_args $(string escape $arg)
end

echo "Command: rsync --archive --verbose --human-readable --progress --one-file-system --ignore-existing $paths $extra_args"
echo
rsync --archive --verbose --human-readable --progress --one-file-system --ignore-existing $paths $extra_args
