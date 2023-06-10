if test -n "$NNNLVL" -a "$NNNLVL" -ge 1
    echo "nnn is already running"
    return
end
set -x NNN_TMPFILE $(mktemp)
command nnn -eauUA
if test -e $NNN_TMPFILE
    source $NNN_TMPFILE
    rm $NNN_TMPFILE
end
