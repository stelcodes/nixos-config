{ pkgs, theme, ... }: {
  home.packages = [ pkgs.starship ];
  xdg.configFile."fish/themes/base16.theme" = {
    onChange = "${pkgs.fish}/bin/fish -c 'echo y | fish_config theme save base16'";
    text = ''
      fish_color_autosuggestion ${theme.bg3x}
      fish_color_cancel -r
      fish_color_command ${theme.bluex}
      fish_color_comment ${theme.bg2x}
      fish_color_cwd ${theme.greenx}
      # fish_color_cwd_root ${theme.redx}
      fish_color_end ${theme.bg3x}
      fish_color_error ${theme.redx}
      # fish_color_escape 00a6b2
      fish_color_history_current --bold
      fish_color_host normal
      fish_color_host_remote ${theme.yellowx}
      fish_color_keyword ${theme.bluex}
      # fish_color_match --background=brblue
      fish_color_normal normal
      fish_color_operator ${theme.yellowx}
      fish_color_option ${theme.cyanx}
      fish_color_param ${theme.cyanx}
      fish_color_quote ${theme.greenx}
      fish_color_redirection ${theme.magentax}
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
      r = "rsync --archive --verbose --human-readable --progress --one-file-system --ignore-existing";
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
      t = "tmux attach";
      tmux = "systemctl --user status tmux.service";
      beep = "timeout -s KILL 0.15 speaker-test --frequency 400 --test sin";
      dl-base = "yt-dlp --embed-metadata --embed-thumbnail --progress";
      dl-video = "${dl-base} --embed-subs --sub-langs 'en' --embed-chapters --sponsorblock-mark 'default' --sponsorblock-remove 'sponsor,selfpromo,outro' --remux-video 'mkv'";
      dl-video-best = "${dl-video} --format best";
      dl-video-1080 = "${dl-video} --format 'worstvideo[height=1080]+bestaudio / best[height<=1080]'";
      dl-video-1080-playlist = "${dl-video-1080} --output '%(playlist)s/%(playlist_index).2d - %(title)s.%(ext)s'";
      dl-music = "${dl-base} --format 'bestaudio' --output \"$HOME/music/library/%(album_artist,artist,uploader,webpage_url)s/%(album,track,title|unknown album)s/%(track_number|00).2d - %(track,title,webpage_url)s.%(ext)s\"";
      dl-music-yt = "${dl-base} --format 'bestaudio' --extract-audio --audio-format opus";
      noansi = "sed \"s,\\x1B\\[[0-9;]*[a-zA-Z],,g\"";
      loggy = "${noansi} | tee ~/tmp/$(date +%F-%T)-log.txt";
      vpn = "doas protonvpn";
      network-test = "ping -c 1 -W 5 8.8.8.8";
      rebuild-direct = "doas nixos-rebuild switch --flake \"$HOME/nixos-config#\"";
      swaytree = "swaymsg -t get_tree | nvim -R";
      nixrepl = "nix repl --file '<nixpkgs/nixos>'";
      nixsize = "nix path-info --closure-size --human-readable --recursive";
    };
    shellAliases = {
      nnn = "n";
    };
    functions = {
      nnn-rsync = builtins.readFile ./nnn-rsync.fish;
      n = builtins.readFile ./n.fish;
    };
  };
}
