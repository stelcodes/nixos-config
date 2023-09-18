# Starts nvim --clean with plugins from selected directories

SEL=${NNN_SEL:-${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

if [ -s "$SEL" ]; then
  RTP=""
  for x in $(<"$SEL"); do
    RTP="$RTP:$x"
  done
  # Clear selection
  if [ -s "$SEL" ] && [ -p "$NNN_PIPE" ]; then
      printf "-" > "$NNN_PIPE"
  fi
  nvim --clean --cmd "set rtp^=$RTP"
else
  nvim --clean
fi

