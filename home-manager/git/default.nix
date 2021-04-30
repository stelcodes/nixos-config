pkgs: {
  programs.git = {
    enable = true;
    userName = "Stel Abrego";
    userEmail = "stel@stel.codes";
    ignores =
      [ "*Session.vim" "*.DS_Store" "*.swp" "*.direnv" "/direnv" "/local" ];
    extraConfig = { init = { defaultBranch = "main"; }; };
  };
}
