{ pkgs, config, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "23.11";

  profile = {
    audio = true;
    battery = false;
    bluetooth = true;
    graphical = true;
    server = true;
    virtual = false;
    virtualHost = false;
  };

  hardware = {
    bluetooth.enable = true;
    opengl.enable = true;
    xpadneo.enable = true;
  };

  age.secrets = {
    root-password.file = ../../secrets/root-password.age;
    admin-password.file = ../../secrets/admin-password.age;
  };

  # Uncomment this when secrets are rekeyed with new system ssh key
  # users.users = {
  #   root.hashedPasswordFile = config.age.secrets.root-password.path;
  #   ${config.admin.username}.hashedPasswordFile = config.age.secrets.admin-password.path;
  # };

  services = {
    getty.autoLoginUser = "${config.admin.username}";
    syncthing = {
      enable = true;
    };
  };
}
