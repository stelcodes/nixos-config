{ pkgs, config, inputs, ... }: {

  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-cpu-intel-sandy-bridge
  ];

  system.stateVersion = "23.11";

  profile = {
    audio = true;
    battery = false;
    bluetooth = true;
    graphical = true;
    virtual = false;
    virtualHost = false;
  };

  hardware = {
    xpadneo.enable = true;
  };

  age.secrets = {
    # root-password.file = ../../secrets/root-password.age;
    # admin-password.file = ../../secrets/admin-password.age;
  };

  # Uncomment this when secrets are rekeyed with new system ssh key
  # users.users = {
  #   root.hashedPasswordFile = config.age.secrets.root-password.path;
  #   ${config.admin.username}.hashedPasswordFile = config.age.secrets.admin-password.path;
  # };

  services = {
    getty.autologinUser = "${config.admin.username}";
    syncthing = {
      enable = true;
      selectedFolders = [ "default" "games" ];
    };
  };
}
