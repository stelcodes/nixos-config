if set --query NNNLVL
    echo "nnn is already running"
    return
end

set -x NNN_TMPFILE $(mktemp)
set -x NNN_SEL $(mktemp)

if test "$TERM_PROGRAM" = "tmux"
  command nnn -eauUAGP p $argv
else
  command nnn -eauUAG $argv
end

if test -e "$NNN_TMPFILE"
    cd $(string sub --start 5 --end -1 < $NNN_TMPFILE)
    rm $NNN_TMPFILE
end

if test -e "$NNN_SEL"
    rm $NNN_SEL
end
