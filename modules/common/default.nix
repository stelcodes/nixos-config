{ pkgs, lib, config, ... }: {
  config = {
    boot.cleanTmpDir = true;

    # Enable networking
    networking.networkmanager.enable = true;
    networking.hosts."127.0.0.1" = [ "lh" ];
    networking.hosts."104.236.219.156" = [ "nube1" ];
    networking.hosts."167.99.122.78" = [ "morado1" ];

    # Set your time zone.
    time.timeZone = "America/Los_Angeles";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

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
    # security.sudo.enable = false;
    # security.acme.email = "stel@stel.codes";
    # security.acme.acceptTerms = true;

    users.mutableUsers = true;
    # Don't forget to set a password with ‘passwd’.
    users.users.stel = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "tty" "dialout" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
      ];
      shell = pkgs.fish;
    };

    programs.fish.enable = lib.mkDefault true;

    environment.systemPackages =
      with pkgs; [
        vim
      # CORE UTILS
      bat
      htop
      procs
      trash-cli
      fd
      neofetch
      httpie
      wget
      ripgrep
      tealdeer
      unzip
      restic
      exa
      just
      fcp
      # PRINTING
      hplip
      # CODING
      git
      nixfmt
      nix-prefetch-github
      sqlite
      dua
    ];

    # Nice to have, required for gnome-disks to work
    services.udisks2.enable = true;

    nixpkgs.config = {
      allowInsecure = true;
      allowUnfree = true;
    };

    nix = {
      nixPath = [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
        "nixos-config=/home/stel/nixos-config/hosts/${config.networking.hostName}/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
      ];
    };
  };
}
