function blank() { printf "\n"; }
function bold() { printf "\033[1m%s\033[0m\n" "$1"; }
function error() { printf "\e[0;31mERROR: %s\e[0m\n" "$1"; read -r; exit 1; }
function success() { printf "\e[0;32m%s\e[0m\n" "$1"; read -r; }
function warn() { printf "\e[0;33m%s\e[0m\n" "$1"; }
function divider() {  printf "%0.s-" {1..80}; blank; }
bold "Starting rekordbox-add!"; blank;
library="$HOME/Music/dj-tools/rekordbox"
if [ ! -d "$library" ]; then
  error "Rekordbox library not found"
else
  bold "Using library: $library"; blank;
fi
for input; do
  divider
  bold "Processing: $input"
  input_ext="${input##*.}"
  final_input="$input"
  if [ ! -f "$input" ]; then
    warning "File does not exist, skipping..."
    continue
  elif [ "$input_ext" = "wav" ] || [ "$input_ext" = "aif" ] || [ "$input_ext" = "aiff" ]; then
    warn "Converting track to flac format..."
    final_input="${input%.*}.flac"
    if [ -e "$final_input" ]; then
      warn "A flac version already exists, skipping..."
      continue
    elif ffmpeg -loglevel error -stats -i "$input" "$final_input"; then
      success "Track converted to flac"
    else
      warning "Conversion failed, skipping..."
      continue
    fi
  fi
  final_input_ext="${final_input##*.}"
  if [ "$final_input_ext" != "flac" ] && [ "$final_input_ext" != "mp3" ]; then
    warn "File isn't flac or mp3 and can't be converted, skipping..."
    continue
  elif [ -f "$final_input" ] && mv -n "$final_input" "$library"; then
    success "Track moved to library"
  else
    warn "Move failed, skipping..."
    continue
  fi
  if [ -f "$input" ] && trash-put "$input"; then
     success "Trashed original file"
  fi
done
