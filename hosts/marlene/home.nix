{ pkgs, ... }: {
  profile = {
    graphical = true;
    battery = true;
    virtual = false;
    virtualHost = false;
    audio = true;
    bluetooth = true;
  };
  activities.coding = true;
  home = {
    username = "stel";
    homeDirectory = "/Users/stel";
    stateVersion = "24.05"; # Please read the comment before changing.
    packages = [
      pkgs.audacity
      # pkgs.jellyfin-media-player not currently available for M1 :( have to get it from brew
    ];
  };
  programs = {
    fish.shellAbbrs.rebuild = "home-manager switch --flake \"$HOME/nixos-config#marlene\"";
  };

  # brew install --cask obsidian kitty syncthing calibre discord firefox gimp musescore protonvpn signal spotify zoom visual-studio-code
}

