pkgs: {
  home.programs.zsh = {
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
      "switch" = "doas nixos-rebuild switch";
      "hg" = "history | grep";
      "wifi" = "nmtui";
      "vpn" = "doas protonvpn connect -f";
      "attach" = "tmux attach -t '$1'";
      "volume-max" = "pactl -- set-sink-volume 0 100%";
      "volume-half" = "pactl -- set-sink-volume 0 50%";
      "volume-mute" = "pactl -- set-sink-volume 0 0%";
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
