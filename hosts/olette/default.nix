{pkgs, ... }: {

  profile = {
    server = true;
    battery = false;
    graphical = false;
    virtual = false;
    virtualHost = false;
  };

  system.stateVersion = "23.11";
}
