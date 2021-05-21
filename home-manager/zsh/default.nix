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
    initExtraFirst = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
    initExtra = ''
      # Initialize starship prompt
      eval "$(starship init zsh)"

      # From https://is.gd/M2fmiv
      zstyle ':completion:*' menu select
      zmodload zsh/complist

      # use the vi navigation keys in menu completion
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history

      # if [ "$TMUX" = "" ]; then tmux attach; fi
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
      # I like minimal, mortalscumbag, refined, steeef
      #theme = "mortalscumbag";
      extraConfig = ''
        bindkey '^[c' autosuggest-accept
      '';
    };
  };
}
