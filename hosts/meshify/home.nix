{ pkgs, inputs, ... }: {

  home = {
    stateVersion = "23.05";
    packages = [
      pkgs.fractal
      inputs.gpt4all-nix.packages.${pkgs.system}.default
    ];
  };
}
