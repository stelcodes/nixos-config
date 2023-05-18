{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    userSettings = {
      "files.autoSave" = "afterDelay";
    };
  };
}
