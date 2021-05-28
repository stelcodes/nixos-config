{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    /home/stel/config/modules/common.nix
    /home/stel/config/modules/server.nix
    <home-manager/nixos>
  ];

  networking.hostName = "morado1";
  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.shellAliases = {
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


  programs.zsh = {
    enable = true;
    promptInit = "eval \"$(starship init zsh)";
    autosuggestions = {
      enable = true;
    };
    ohMyZsh = {
      enable = true;
      plugins = [ "httpie" "colored-man-pages" ];
    };
  };

  # home-manager = {
  #   useGlobalPkgs = true;
  #   users.stel = { config, ... }: {}
  # };

}
