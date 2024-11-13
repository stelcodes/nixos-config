# Create flake.nix for dev environment from gist template and setup direnv
if [ -e flake.nix ]; then
  printf "ERROR: Nix flake already exists"
  exit 1
fi
if [ ! -d .git ]; then
  printf "ERROR: CWD is not a git repository"
  exit 1
fi
# git status --porcelain only prints something if worktree is dirty
if [ -n "$(git status --porcelain)" ]; then
  printf "ERROR: Git working tree is dirty"
  exit 1
fi
tmpfile="$(mktemp)"
gh gist view -r | tee "$tmpfile"
read -rp "Press enter to create this flake.nix or ctrl+c to quit"
state="garbage"
while IFS= read -r line; do
  if [ "$state" = "garbage" ] && [ -z "$line" ]; then
    state="gist"
  fi
  if [ "$state" = "gist" ]; then
    printf "%s\n" "$line" >> flake.nix
  fi
done < "$tmpfile"
rm "$tmpfile"
if [ ! -e flake.nix ]; then
  printf "ERROR: flake.nix was not created"
  exit 1
fi
git add flake.nix
nix flake lock
printf 'use flake' > .envrc
git add flake.lock .envrc
git commit -m "Add Nix flake and direnv integration"
direnv allow
