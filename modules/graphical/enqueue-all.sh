# Enqueues all songs in the current working directory recursively and ensures playback

# Try to start audacious service to create totally independent process
systemctl --user start audacious.service || true

FLAG="--enqueue-to-temp"

if [ "$(playerctl --player=audacious status)" = "Playing" ]; then
  FLAG="--enqueue"
fi

audacious "$FLAG" "$2"
