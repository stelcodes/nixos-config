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
  theme.name = "catppuccin-macchiato";
  home = {
    username = "stel";
    homeDirectory = "/Users/stel";
    stateVersion = "24.05"; # Please read the comment before changing.
    packages = [
      pkgs.audacity
    ];
  };
  programs = {
    fish.shellAbbrs.rebuild = "home-manager switch --flake \"$HOME/nixos-config#marlene\"";
  };
}

