{ pkgs, ... }: {
  home = {
    stateVersion = "23.11";
    packages = [
      pkgs.obsidian-jailed
    ];
  };
}
