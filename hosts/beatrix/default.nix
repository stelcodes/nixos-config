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

  # Uncomment this when secrets are rekeyed with new system ssh key
  # age.secrets = {
  #   root-password.file = ../../secrets/root-password.age;
  #   admin-password.file = ../../secrets/admin-password.age;
  # };
  # users.users = {
  #   root.hashedPasswordFile = config.age.secrets.root-password.path;
  #   ${config.admin.username}.hashedPasswordFile = config.age.secrets.admin-password.path;
  # };

  fileSystems = {
    "/run/media/archive" = {
      device = "/dev/disk/by-uuid/3101471b-eff2-44d5-97ba-90f74552948f";
      fsType = "ext4";
    };
  };

  services = {
    getty.autologinUser = "${config.admin.username}";
    syncthing.enable = true;
  };
}
