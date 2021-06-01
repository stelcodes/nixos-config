pkgs:
pkgs.lib.mkMerge [{
  xdg = {
    userDirs = {
      enable = true;
      desktop = "$HOME/desktop";
      documents = "$HOME/documents";
      download = "$HOME/downloads";
      music = "$HOME/music";
      pictures = "$HOME/pictures";
      publicShare = "$HOME/public";
      templates = "$HOME/template";
      videos = "$HOME/videos";
    };
  };
  home = {
    username = "stel";
    stateVersion = "21.03";
    # I'm putting all manually installed executables into ~/.local/bin 
    sessionPath = [ "$HOME/.local/bin" ];
  };
  programs.home-manager.enable = true;
}]
