pkgs: {
  home.packages = [
    # zsh prompt
    pkgs.starship
  ];
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    dirHashes = { desktop = "$HOME/Desktop"; };
    initExtra = ''
      # Initialize starship prompt
      eval "$(starship init zsh)"
    '';
    shellAliases = {
      "nix-search" = "nix repl '<nixpkgs>'";
      "source-zsh" = "source $HOME/.config/zsh/.zshrc";
      "source-tmux" = "tmux source-file ~/.tmux.conf";
      "update" = "doas nix-channel --update";
      "switch" = "doas nixos-rebuild switch";
      "hg" = "history | grep";
      "wifi" = "nmtui";
      "vpn" = "doas protonvpn connect -f";
      "attach" = "tmux attach";
      "gui" = "exec sway";
      "absolutepath" = "realpath -e";
      "ls" = "exa";
      "grep" = "rg";
      "restic-backup-napi" =
        "restic -r /run/media/stel/Napi/restic-backups/ backup --files-from=/home/stel/config/misc/restic/include.txt --exclude-file=/home/stel/config/misc/restic/exclude.txt";
      "restic-mount-napi" =
        "restic -r /run/media/stel/Napi/restic-backups/ mount /home/stel/backups/Napi-restic";
      "restic-backup-mapache" =
        "restic -r /run/media/stel/Mapache/restic-backups/ backup --files-from=/home/stel/config/misc/restic/include.txt --exclude-file=/home/stel/config/misc/restic/exclude.txt";
      "restic-mount-mapache" =
        "restic -r /run/media/stel/Mapache/restic-backups/ mount /home/stel/backups/Mapache-restic";
      "pdf" = "evince-previewer";
      "play-latest-obs-recording" =
        "mpv $(ls /home/stel/videos/obs | sort --reverse | head -1)";
      # Creating this alias because there's a weird bug with the clj command producing this error on nube1:
      # rlwrap: error: Cannot execute BINDIR/clojure: No such file or directory
      "clj" = "clojure";
      "screenshot" =
        "slurp | grim -g - ~/pictures/screenshots/grim:$(date -Iseconds).png";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        # docker completion
        "docker"
        # self explanatory
        "colored-man-pages"
        # completion + https command
        "httpie"
        # pp_json command
        "jsontools"
      ];
    };
  };
}
