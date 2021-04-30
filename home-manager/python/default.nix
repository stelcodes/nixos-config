pkgs: {
  home.packages = [
    # (pkgs.python3.withPackages (py-pkgs: [py-pkgs.swaytools])) this would work but swaytools isn't in the nixos python modules
    pkgs.python39
    pkgs.python39Packages.pip
    # pip packages: swaytools
    # pip install --user <package>
    # This installs the package in ~/.local
    # The source will go in ~/.local/lib and the binaries will go in ~/.local/bin
  ];
}
