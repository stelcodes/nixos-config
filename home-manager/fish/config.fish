if status is-interactive
  # Commands to run in interactive sessions can go here
  fish_vi_key_bindings
  fish_add_path /nix/var/nix/profiles/default/bin ~/.nix-profile/bin ~/.cargo/bin ~/go/bin ~/.local/bin
  fzf_configure_bindings --variables=\e\cE --history=\e\cR
  # Important environment variables
  set -x BROWSER "firefox"
  set -x EDITOR "nvim"
  set -x PAGER "less --chop-long-lines --RAW-CONTROL-CHARS"
  set -x MANPAGER 'nvim +Man!'
  # For puppetdb work on my work machine
  set -x PDBBOX ~/tmp/pdb-sandbox
  set -x PUPPET_SUPPRESS_INTERNAL_LEIN_REPOS 1
  set -x PDB_TEST_KEEP_DB_ON_FAIL true
  # This sets the theme for bat and delta
  set -x LS_COLORS "di=1;34:ln=32:so=33:pi=33:ex=33:bd=33;46:cd=33;43:su=33;47:sg=33;47:tw=36;45:ow=30;41"
  set -x BAT_THEME 'base16'
  # fzf dracula color scheme
  set -x FZF_DEFAULT_OPTS "--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4"
  # nnn settings
  set -x NNN_TRASH 1
  set -x NNN_PLUG 'p:preview-tui;d:dragdrop'
  set -x NNN_TMPFILE '/tmp/nnn-last-dir'
  set -x NNN_FCOLORS "030304030705020801030301"
  function n
    env SHELL=/usr/bin/fish nnn -eauUA
    # cd into directory when quitting
    cd $(cat /tmp/nnn-last-dir | string sub --start 5 --end -1)
  end
  # Aliases
  alias ll 'ls -l'
  alias la 'ls --almost-all'
  alias l 'ls -C --classify'
  alias gs 'git status'
  alias gl 'git fancy-log'
  alias glo 'git log --oneline'
  alias rm 'rm --interactive'
  alias mv 'mv --no-clobber'
  alias t 'tmux attach -t config; or tmux'
  alias beep "aplay --quiet ~/music/sound-effects/ding-ding.wav"
  alias alert 'notify-send "Terminal alert! 🐢"'
  alias cp "cp -n"
  # Like startx, start wayland, qt setting
  alias startw "exec ~/.config/scripts/start-sway.sh"
  # Debian installs batcat, Fedora installs bat
  if test (command -s batcat)
    alias bat 'batcat --theme=base16 --style=header'
  else
    alias bat 'bat --theme=base16 --style=header'
  end
  # Debian installs fdfind, Fedora installs bat
  if test (command -s fdfind)
    alias fd "fdfind"
  end
  # If python is not viable command and python3 is, make an alias
  if test (command -s python3) && not test (command -s python)
    alias python "python3"
  end
  alias r "rsync --archive --verbose --human-readable --progress --one-file-system --ignore-existing"
  alias s "source ~/.config/fish/config.fish && echo 'config reloaded ✨'"
  alias dl-base "yt-dlp --embed-metadata --embed-thumbnail --progress"
  alias dl-video "dl-base --embed-subs --sub-langs 'en' --embed-chapters --sponsorblock-mark 'default' --sponsorblock-remove 'sponsor,selfpromo,outro' --remux-video 'mkv'"
  alias dl-video-best "dl-video --format best"
  alias dl-video-1080 "dl-video --format 'worstvideo[height=1080]+bestaudio / best[height<=1080]'"
  alias dl-video-1080-playlist "dl-video-1080 --output '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"
  alias dl-music "dl-base --format 'bestaudio[ext=ogg] / bestaudio[ext=mp3]' --output '/home/stel/music/collection/%(album_artist,artist|unknown artist)s/%(album,track|unknown album)s/%(track_number|0)s %(track,id,epoch)s.%(ext)s'"
  alias dl-samples "dl-base --format 'bestaudio[ext=ogg] / bestaudio[ext=mp3]' --output '/home/stel/music/samples/%(album_artist,artist|unknown artist)s/%(album,track|unknown album)s/%(track_number|0)s %(track,id,epoch)s.%(ext)s'"
  alias dl-music-best "dl-music --format 'bestaudio[ext=flac] / bestaudio[ext=ogg] / bestaudio[ext=mp3]'"
  alias dl-music-yt "dl-base --format 'bestaudio' --extract-audio --audio-format opus"
  alias new-ssh-key "ssh-keygen -t ed25519 -C 'stel@stel.codes'"
  alias c "FZF_DEFAULT_COMMAND='fd --hidden --type d' cd (fzf)"
  alias noansi 'sed "s,\x1B\[[0-9;]*[a-zA-Z],,g"'
  alias loggy 'noansi | tee ~/tmp/$(date +%F-%T)-log.txt'
  # Don't show cover art in separate window when playing music files
  alias mpv 'mpv --audio-display=no'
  alias reload-fonts 'fcache -v'
  # ISO 8601 date format with UTC timezone
  alias date-iso 'date -u +"%Y-%m-%dT%H:%M:%SZ"'
  alias clj "rlwrap bb clojure"
  alias backup-home "restic backup --exclude-caches --exclude-file ~/.config/restic/exclude.txt --one-file-system --exclude-larger-than 1G $HOME"
  alias bigstuff "dust -n 100 -d 1"
  alias d "dua --stay-on-filesystem interactive"
  alias backup-directory-dangerously "bb ~/.config/scripts/backup-directory-dangerously.clj"
  alias funnel 'bb clojure -Sdeps \'{:deps {lambdaisland/funnel {:mvn/version "1.4.71"}}}\' -m lambdaisland.funnel'
  alias dnf-upgrade-kernel "sudo dnf upgrade 'kernel*' --disableexcludes main"
  alias dnf-with-kernel "sudo dnf --disableexcludes main"
  alias config 'cd ~/.config && nvim'
  alias sc 'systemctl'
  alias scu 'systemctl --user'
  alias jc 'journalctl'
  alias jcu 'journalctl --user'
  function dnf-version-upgrade
    set --function cv $(cat /etc/fedora-release | string match --regex 'Fedora release (\d\d)' --groups-only)
    read --function --prompt "echo 'Version number (a number 30-60, current version is $cv): '" v
    if string match --quiet --invert --regex '^\d\d$' "$v" || test 30 -gt "$v" || test "$v" -gt 50
      echo "Error: must be a number between 30 and 50"
      return 1
    end
    read --function --prompt "echo 'Is version number $v correct? (y/N): '" c
    if string match --quiet --invert --regex '^[yY]$' "$c"
      echo "Aborting fedora major release upgrade..."
      return 1
    end
    echo "Commencing upgrade 🤖💞"
    sudo dnf upgrade --disableexcludes main --refresh && \
    sudo dnf system-upgrade download --disableexcludes main --releasever="$v" --best --allowerasing && \
    sudo dnf system-upgrade reboot --disableexcludes main
  end

  # Make prompt
  starship init fish | source
  direnv hook fish | source
end
