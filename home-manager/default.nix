pkgs: {

  home = {
    username = "stel";
    homeDirectory = "/home/stel";

    packages = [
      # process monitoring
      pkgs.htop
      pkgs.procs
      # cross platform trash bin
      pkgs.trash-cli
      # alternative find, also used for fzf
      pkgs.fd
      # system info
      pkgs.neofetch
      # http client
      pkgs.httpie
      # download stuff from the web
      pkgs.wget
      # searching text
      pkgs.ripgrep
      # documentaion
      pkgs.tealdeer
      # archiving
      pkgs.unzip
      # backups
      pkgs.restic
      # ls replacement
      pkgs.exa
      # math
      pkgs.rink
      # nix
      pkgs.nixfmt
      pkgs.nix-index
      pkgs.nix-prefetch-github
    ];

    file = {
      ".clojure/deps.edn".source = /home/stel/config/misc/deps.edn;
      ".npmrc".text = "prefix = \${HOME}/.npm-packages";
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "21.03";

    # I'm putting all manually installed executables into ~/.local/bin 
    sessionPath = [
      "$HOME/.cargo/bin"
      "$HOME/go/bin"
      "$HOME/.local/bin"
      "$HOME/.npm-packages/bin"
    ];
    sessionVariables = { };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat = {
      enable = true;
      config = { theme = "base16"; };
    };
  };
}
