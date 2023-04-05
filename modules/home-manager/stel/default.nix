{pkgs, ...}: {
  imports = [];
  # TODO: neovim, git, tmux, alacritty, sway, zsh
  config = {
    home-manager.users.stel = {
      programs.fish.enable = true;

      programs.neovim = {
        enable = true;
      };

      programs.git = {
        enable = true;
        userName = "Stel Abrego";
        userEmail = "stel@stel.codes";
        ignores = [ "*~" "*.swp" "*.#" ];
        delta.enable = true;
        extraConfig = {
          core.editor = "nvim";
          init.defaultBranch = "main";
          pull.rebase = "true";
          url = {
            "git@github.com:".insteadOf = "https://github.com/";
          };
        };
      };


  programs.tmux.enable = true;

      packages = with pkgs; [
        # QUALITY OF LIFE
        pavucontrol
        xdg-utils
        # NETWORKING
        protonvpn-cli
        libimobiledevice # For iphone hotspot tethering
        # DISKS
        gnome.gnome-disk-utility
        etcher
        gparted
        # SECRETS
        keepassxc
      ];

    home.stateVersion = "22.11";
    home.packages = with pkgs; [
    ];
  };
};
}

