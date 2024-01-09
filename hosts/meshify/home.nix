{ pkgs, inputs, ... }: {

  home = {
    stateVersion = "23.05";
    packages = [
      pkgs.fractal
      inputs.gpt4all-nix.packages.${pkgs.system}.default
      inputs.arcsearch.defaultPackage.${pkgs.system}
    ];
  };
  wayland.windowManager.sway.config.workspaceOutputAssign = [
    {
      output = "HDMI-A-1";
      workspace = "5";
    }
  ];
}
