{pkgs, ...}: {
  useUserPackages = true;
  useGlobalPkgs = true;

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  systemd.user.startServices = true;

  programs.direnv.enable = true;
}

