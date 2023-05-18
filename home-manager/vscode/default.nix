{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = true;
    enableExtensionUpdateCheck = true;
    mutableExtensionsDir = true;
    userSettings = {
      "files.autoSave" = "afterDelay";
      "workbench.colorTheme" = "Nord";
      # Fixes issue of caps lock escape not working
      "keyboard.dispatch" = "keyCode";
      "vim.useSystemClipboard" = true;
      # So I can use <c-o> to open file
      "vim.useCtrlKeys" = false;
      "editor.renderWhitespace" = "trailing";
    };
    extensions = [
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.arcticicestudio.nord-visual-studio-code
      pkgs.vscode-extensions.bbenoist.nix
      pkgs.vscode-extensions.bungcip.better-toml
    ];
  };
}
