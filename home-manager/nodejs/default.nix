pkgs: {
  home = {
    packages = [ pkgs.nodejs ];
    sessionPath = [ "$HOME/.npm-packages/bin" ];
    file = { ".npmrc".text = "prefix = \${HOME}/.npm-packages"; };
  };
}
