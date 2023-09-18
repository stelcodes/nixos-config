# Starts nvim --clean with plugins from selected directories

SEL=${NNN_SEL:-${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

if [ -s "$SEL" ]; then
  EXTRA_ARGS=""
  for PLUGIN_DIR in $(<"$SEL"); do
    EXTRA_ARGS="$EXTRA_ARGS --cmd 'set runtimepath^=$PLUGIN_DIR'"
  done
  echo "$EXTRA_ARGS" | xargs nvim --clean
fi
