pkgs: {
  xdg.configFile = {
    "alacritty/alacritty.yml".text = pkgs.lib.mkMerge [
      ''
        shell:
          program: ${pkgs.zsh}/bin/zsh''
      (builtins.readFile /home/stel/config/misc/alacritty-base.yml)
      (builtins.readFile /home/stel/config/misc/alacritty-nord.yml)
    ];
  };
  programs.alacritty = { enable = true; };
}
