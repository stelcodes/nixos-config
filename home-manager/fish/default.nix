pkgs: {
  home.packages = [ pkgs.starship ];
  programs.fish = {
    enable = true;
    interactiveShellInit = builtins.readFile ./interactive.fish;
    shellAbbrs = {
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
      jc = "journalctl";
      jcu = "journalctl --user";
      config = "cd ~/nixos-config && nvim";
      d = "dua --stay-on-filesystem interactive";
      new-shh-key = "ssh-keygen -t ed25519 -C 'stel@stel.codes'";
      # ISO 8601 date format with UTC timezone
      date-iso = "date -u +\"%Y-%m-%dT%H:%M:%SZ\"";
    };
  };
}
