{ pkgs, config, ... }: {
  config = {

    # hosts
    networking.hosts = { "104.236.219.156" = [ "nube1" ]; };

    # Set your time zone.
    time.timeZone = "America/Detroit";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    console = {
      font = "Lat2-Terminus16";
      # keyMap = "us";
      useXkbConfig = true;
    };

    security = {
      doas = {
        enable = true;
        extraRules = [{
          users = [ "stel" ];
          keepEnv = true;
          noPass = true;
          # persist = true;
        }];
      };
      sudo.enable = false;
      acme = {
        email = "stel@stel.codes";
        acceptTerms = true;
      };
    };

    users = {
      mutableUsers = true;
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users = {
        stel = {
          home = "/home/stel";
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "jackaudio" "audio" ];
          shell = pkgs.zsh;
        };
      };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [ zsh starship neovim ];

  };
}
