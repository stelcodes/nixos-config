{ pkgs, ... }: {
  config = {
    environment.systemPackages = with pkgs; [ alacritty ];
    # ln -s /etc/alacritty.yml $HOME/.alacritty.yml
    environment.etc."alacritty.yml".text = pkgs.lib.mkMerge [
      ''
        shell:
          program: ${pkgs.zsh}/bin/zsh''
      (builtins.readFile ./alacritty-base.yml)
      (builtins.readFile ./alacritty-nord.yml)
    ];
  };
}
