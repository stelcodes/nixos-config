# Enqueues the selection or the hovered file if nothing is selected and ensures playback

# Try to start audacious service to create totally independent process
systemctl --user start audacious.service || true

SEL=${NNN_SEL:-${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}
FLAG="--enqueue-to-temp"

if [ "$(playerctl --player=audacious status)" = "Playing" ]; then
  FLAG="--enqueue"
fi

if [ -s "$SEL" ]; then
    xargs -0 audacious "$FLAG" < "$SEL"
    # Clear selection
    if [ -s "$SEL" ] && [ -p "$NNN_PIPE" ]; then
        printf "-" > "$NNN_PIPE"
    fi
elif [ -n "$1" ]; then
    audacious "$FLAG" "$1"
fi
