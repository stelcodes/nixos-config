{ pkgs, ... }: {
  config = {
    programs.zsh.enable = true;
    programs.zsh.shellAliases = {
      "nix-search" = "nix repl '<nixpkgs>'";
      "source-zsh" = "source /etc/zsh/zshrc";
      "source-tmux" = "tmux source-file /etc/tmux.conf";
      "update" = "doas nix-channel --update";
      "switch" = "doas nixos-rebuild switch";
      "hg" = "history | grep";
      "absolutepath" = "realpath -e";
      "bat" = "bat --theme=base16";
      "gs" = "git status";
      "ga" = "git add";
      "gc" = "git commit";
    };
    programs.zsh.promptInit = ''eval "$(starship init zsh)"'';
    programs.zsh.shellInit = ''
      path+=('/home/stel/.local/bin')
    '';
    programs.zsh.autosuggestions.enable = true;
    programs.zsh.ohMyZsh.enable = true;
    programs.zsh.ohMyZsh.plugins = [ "httpie" "colored-man-pages" ];
  };
}
