# Enqueues all songs in the current working directory recursively and ensures playback

FLAG="--enqueue-to-temp"

if [ "$(playerctl --player=audacious status)" = "Playing" ]; then
  FLAG="--enqueue"
fi

audacious "$FLAG" "$2"
