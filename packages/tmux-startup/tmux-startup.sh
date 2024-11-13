if tmux run &>/dev/null; then
  tmux new-window -t sandbox:
  tmux new-session -As sandbox
else
  tmux new-session -ds config -c "$HOME/.config/nix"
  tmux new-session -ds media
  tmux new-session -As sandbox
fi
