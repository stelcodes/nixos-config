pkgs: {
  xdg.configFile = {
    "alacritty/alacritty.yml".text = pkgs.lib.mkMerge [
      ''
        shell:
          program: ${pkgs.fish}/bin/fish''
      (builtins.readFile ./alacritty-base.yml)
      (builtins.readFile ./alacritty-nord.yml)
    ];
  };
  programs.alacritty = { enable = true; };
}
