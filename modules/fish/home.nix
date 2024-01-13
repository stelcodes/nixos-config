{ pkgs, ... }: {
  home.packages = [ pkgs.starship ];
  xdg.configFile."fish/themes/base16.theme" = {
    onChange = "${pkgs.fish}/bin/fish -c 'echo y | fish_config theme save base16'";
    text = ''
      fish_color_autosuggestion brblack
      fish_color_cancel -r
      fish_color_command blue
      fish_color_comment brblack
      fish_color_cwd green
      fish_color_cwd_root red
      fish_color_end brblack
      fish_color_error red
      fish_color_escape yellow
      fish_color_history_current --bold
      fish_color_host normal
      fish_color_host_remote yellow
      fish_color_keyword blue
      # fish_color_match --background=brblue
      fish_color_normal normal
      fish_color_operator yellow
      fish_color_option cyan
      fish_color_param cyan
      fish_color_quote green
      fish_color_redirection magenta
      # fish_color_search_match 'bryellow'  '--background=brblack'
      fish_color_selection 'white'  '--bold'  '--background=brblack'
      # fish_color_status red
      # fish_color_user brgreen
      fish_color_valid_path --underline
      fish_pager_color_background
      fish_pager_color_completion normal
      fish_pager_color_description 'yellow'
      fish_pager_color_prefix 'normal'  '--bold'  '--underline'
      fish_pager_color_progress 'brwhite'  '--background=cyan'
      fish_pager_color_secondary_background
      fish_pager_color_secondary_completion
      fish_pager_color_secondary_description
      fish_pager_color_secondary_prefix
      fish_pager_color_selected_background --background=brblack
      fish_pager_color_selected_completion
      fish_pager_color_selected_description
      fish_pager_color_selected_prefix
    '';
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting (printf (_ '🐟 don\'t be afraid to ask for %shelp%s 💞') (set_color green) (set_color normal))
      fish_vi_key_bindings
      ${pkgs.starship}/bin/starship init fish | source
      # Maybe add direnv sourcing here later
    '';
    loginShellInit = ''
      ${pkgs.neofetch}/bin/neofetch
      ${pkgs.pomo}/bin/pomo start
    '';
    shellAbbrs = rec {
      ll = "ls -l";
      la = "ls -A";
      rm = "rm -i";
      mv = "mv -n";
      r = "rsync -rltxhv";
      gs = "git status";
      gl = "git log";
      glo = "git log --oneline";
      gf = "log --pretty=format:'%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(cyan)%cr%C(reset) %s %C(green)%d%C(reset)' --graph";
      sc = "systemctl";
      scu = "systemctl --user";
      jc = "journalctl -ex --unit";
      jcu = "journalctl --user -ex --unit";
      config = "cd ~/nixos-config; nvim";
      d = "dua --stay-on-filesystem interactive";
      new-ssh-key = "ssh-keygen -t ed25519 -C 'stel@stel.codes'";
      date-sortable = "date +%Y-%m-%dT%H:%M:%S%Z"; # ISO 8601 date format with local timezone
      date-sortable-utc = "date -u +%Y-%m-%dT%H:%M:%S%Z"; # ISO 8601 date format with UTC timezone
      t = "tmux attach || tmux new-session -s config -c \"$HOME/nixos-config\"";
      beep = "timeout -s KILL 0.15 speaker-test --frequency 400 --test sin";
      dl-base = "yt-dlp --embed-metadata --embed-thumbnail --progress";
      dl-video = "${dl-base} --embed-subs --sub-langs 'en' --embed-chapters --sponsorblock-mark 'default' --sponsorblock-remove 'sponsor,selfpromo,outro' --remux-video 'mkv'";
      dl-video-best = "${dl-video} --format best";
      dl-video-1080 = "${dl-video} --format 'worstvideo[height=1080]+bestaudio / best[height<=1080]'";
      dl-video-1080-playlist = "${dl-video-1080} --output '%(playlist)s/%(playlist_index).2d - %(title)s.%(ext)s'";
      dl-music = "${dl-base} --format 'bestaudio' --output \"%(album_artist,artist,uploader|Unknown Artist)s/%(album_artist,artist,uploader|Unknown Artist)s - %(album,track,title|Unknown Album)s/%(track_number|00).2d - %(artist,uploader|Unknown Artist)s - %(track,title,webpage_url)s.%(ext)s\"";
      dl-music-yt = "${dl-base} --format 'bestaudio' --extract-audio --audio-format opus";
      dl-yarn = "${dl-base} --extract-audio --audio-format flac --output \"$HOME/music/samples/yarn/$(read).%(ext)s\"";
      noansi = "sed \"s,\\x1B\\[[0-9;]*[a-zA-Z],,g\"";
      loggy = "${noansi} | tee ~/tmp/$(date +%F-%T)-log.txt";
      network-test = "ping -c 1 -W 5 8.8.8.8";
      rebuild-direct = "doas nixos-rebuild switch --flake \"$HOME/nixos-config#\"";
      swaytree = "swaymsg -t get_tree | nvim -R";
      swayinputs = "swaymsg -t get_inputs | nvim -R";
      swayoutputs = "swaymsg -t get_outputs | nvim -R";
      nix-repl-flake = "nix repl --expr \"(builtins.getFlake (toString $HOME/nixos-config)).nixosConfigurations.$hostname\"";
      nix-pkg-size = "nix path-info --closure-size --human-readable --recursive";
      play = "audacious --enqueue-to-temp";
      notes = "cd ~/documents/journal && nvim";
      strip-exec-permissions = "if test \"$(read -P 'Are you sure: ')\" = 'y'; fd -0 --type x | xargs -0 chmod -vc a-x; else; echo 'Aborting'; end";
      sway = "exec systemd-cat --identifier=sway sway";
      u = "udisksctl";
      wg-killswitch-disable = "if test \"$(read -P 'Disable wg-killswitch? ')\" = 'y'; doas iptables --flush wg-killswitch; doas ip6tables --flush wg-killswitch; else; false; end";
      nix-shell-nixpkgs = "nix shell --file .";
      nix-shell-default = "nix shell --impure --include nixpkgs=flake:nixpkgs --expr 'with import <nixpkgs> {}; { default = callPackage ./default.nix {}; }' default";
      nix-dependency = "nix-store --query --referrers /nix/store/";
      nix-bigstuff = "nix path-info -rS /run/current-system | sort -nk2";
      nix-why = "nix why-depends /run/current-system /nix/store/";
    };
    shellAliases = {
      nnn = "n";
    };
    functions = {
      n = builtins.readFile ./n.fish;
      wallpaper = /* fish */ ''
        cp -i "$argv[1]" "$HOME/.wallpaper"
      '';
    };
  };
}
