{ pkgs, ... }: {
  profile = {
    graphical = true;
    battery = false;
    virtual = false;
    virtualHost = false;
    audio = false;
    bluetooth = false;
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

