fish_vi_key_bindings
fish_add_path /nix/var/nix/profiles/default/bin ~/.nix-profile/bin ~/.cargo/bin ~/go/bin ~/.local/bin

# ENVIRONMENT #################################################################
# Important environment variables
set -x BROWSER "firefox"
set -x EDITOR "nvim"
set -x PAGER "less --chop-long-lines --RAW-CONTROL-CHARS"
set -x MANPAGER 'nvim +Man!'
# This sets the theme for bat and delta
set -x BAT_THEME 'base16'
set -x NNN_TRASH 1
set -x NNN_PLUG 'p:preview-tui;d:dragdrop'
set -x NNN_TMPFILE '/tmp/nnn-last-dir'
set -x NNN_FCOLORS "030304030705020801030301"

# FUNCTIONS ###################################################################
function n
  nnn -eauUA
  # cd into directory when quitting
  cd $(cat /tmp/nnn-last-dir | string sub --start 5 --end -1)
end

set -g fish_greeting (printf (_ '🐟 don\'t be afraid to ask for %shelp%s 💞') (set_color green) (set_color normal))
starship init fish | source
direnv hook fish | source
