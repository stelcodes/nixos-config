if set --query NNNLVL
    echo "nnn is already running"
    return
end

set -x NNN_TMPFILE $(mktemp)

if test $TERM_PROGRAM = "tmux"
  command nnn -eauUAP p $argv
else
  command nnn -eauUA $argv
end

if test -e $NNN_TMPFILE
    source $NNN_TMPFILE
    rm $NNN_TMPFILE
end
