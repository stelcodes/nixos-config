{ pkgs, ... }: {
  imports = [ ../neovim ../zsh ../tmux ../git ];

  config = {
    boot.cleanTmpDir = true;

    # hosts
    networking.hosts."104.236.219.156" = [ "nube1" ];
    networking.hosts."167.99.122.78" = [ "morado1" ];

    # Set your time zone.
    time.timeZone = "America/Detroit";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    console.font = "Lat2-Terminus16";
    console.useXkbConfig = true;
    # console.keyMap = "us";

    security.doas.enable = true;
    security.doas.extraRules = [{
      users = [ "stel" ];
      keepEnv = true;
      noPass = true;
      # persist = true;
    }];
    security.sudo.enable = false;
    security.acme.email = "stel@stel.codes";
    security.acme.acceptTerms = true;

    users.mutableUsers = true;
    # Don't forget to set a password with ‘passwd’.
    users.users.stel = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "jackaudio" "audio" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
      ];
      shell = pkgs.zsh;
    };

    environment.variables.BROWSER = "firefox";
    environment.variables.EDITOR = "nvim";
    environment.systemPackages = with pkgs; [
      zsh
      starship
      neovim
      git
      bat
      # process monitoring
      htop
      procs
      # cross platform trash bin
      trash-cli
      # alternative find, also used for fzf
      fd
      # system info
      neofetch
      # http client
      httpie
      # download stuff from the web
      wget
      # searching text
      ripgrep
      # documentaion
      tealdeer
      # archiving
      unzip
      # backups
      restic
      # ls replacement
      exa
      # make replacement
      just
      # math
      rink
      # nix
      nixfmt
      nix-prefetch-github
      # timeless db
      sqlite
      # for urlview tmux plugin
      urlview
    ];
  };
}
