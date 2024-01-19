{ pkgs, inputs, ... }: {

  home = {
    stateVersion = "23.05";
    packages = [
      pkgs.obsidian
      pkgs.gimp-with-plugins
      pkgs.gajim
      pkgs.signal-desktop
      pkgs.fractal
      inputs.gpt4all-nix.packages.${pkgs.system}.default
      inputs.arcsearch.defaultPackage.${pkgs.system}
      pkgs.retroarch-loaded
      pkgs.kodi-loaded
      pkgs.discord-firefox
    ];
  };
  wayland.windowManager.sway.config.workspaceOutputAssign = [
    { output = "HDMI-A-1"; workspace = "5"; }
  ];
}
