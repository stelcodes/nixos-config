if set --query NNNLVL
    echo "nnn is already running"
    return
end

set -x NNN_TMPFILE $(mktemp)
set -x NNN_SEL $(mktemp)

# I don't actually like when preview is on by default
# if test "$TERM_PROGRAM" = "tmux"
#   command nnn -eauUAGP p $argv

command nnn -oeauUAG $argv

if test -e "$NNN_TMPFILE"
    cd $(string sub --start 5 --end -1 < $NNN_TMPFILE)
    rm $NNN_TMPFILE
end

if test -e "$NNN_SEL"
    rm $NNN_SEL
end
