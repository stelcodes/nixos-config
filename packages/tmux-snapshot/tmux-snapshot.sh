if tmux has-session &>/dev/null; then
  printf "tmux is running, saving snapshot..."
  "@tmux_resurrect@/share/tmux-plugins/resurrect/scripts/save.sh" quiet
else
  printf "tmux is not running"
fi
