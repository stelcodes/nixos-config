{ pkgs, theme, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    userSettings = {
      "files.autoSave" = "afterDelay";
      "workbench.colorTheme" = theme.vscode.themeName;
      # Fixes issue of caps lock escape not working
      "keyboard.dispatch" = "keyCode";
      "vim.useSystemClipboard" = true;
      # So I can use <c-o> to open file
      "vim.useCtrlKeys" = false;
      "editor.renderWhitespace" = "trailing";
    };
    extensions = [
      theme.vscode.extension
      pkgs.vscode-extensions.vscodevim.vim
      pkgs.vscode-extensions.bbenoist.nix
      pkgs.vscode-extensions.bungcip.better-toml
      pkgs.vscode-extensions.betterthantomorrow.calva
    ];
  };
}
