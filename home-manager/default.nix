pkgs: {

  systemd.user.startServices = true;

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
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
      # make replacement
      pkgs.just
      # math
      pkgs.rink
      # nix
      pkgs.nixfmt
      pkgs.nix-prefetch-github
      # timeless db
      pkgs.sqlite
    ];

    # I'm putting all manually installed executables into ~/.local/bin
    sessionPath = [ "$HOME/.local/bin" ];
    # sessionVariables = {
    #   SHELL = "${pkgs.zsh}/bin/zsh";
    #   EDITOR = "${pkgs.neovim}/bin/nvim";
    # };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat = {
      enable = true;
      config = { theme = "base16"; };
    };

    git = {
      enable = true;
      userName = "Stel Abrego";
      userEmail = "stel@stel.codes";
      ignores = [
        "*Session.vim"
        "*.DS_Store"
        "*.swp"
        "*.direnv"
        "/direnv"
        "/local"
        "/node_modules"
        "*.jar"
        "*~"
        "*.swp"
        "*.#"
      ];
      delta.enable = true;
      extraConfig = {
        core.editor = "nvim";
        init = { defaultBranch = "main"; };
        merge = { ff = "only"; };
        # url = {
        #   "git@github.com:".insteadOf = "https://github.com/";
        # };
        # pull.rebase = "true";
      };
    };

    fzf = let
      fzfExcludes = [
        ".local"
        ".cache"
        ".git"
        "node_modules"
        ".rustup"
        ".cargo"
        ".m2"
        ".bash_history"
      ];
      # string lib found here https://git.io/JtIua
      fzfExcludesString =
        pkgs.lib.concatMapStrings (glob: " --exclude '${glob}'") fzfExcludes;
    in {
      enable = false;
      defaultOptions = [ "--height 80%" "--reverse" ];
      defaultCommand = "fd --type f --hidden ${fzfExcludesString}";
    };

    direnv = {
      enable = true;
      # I wish I could get nix-shell to work with clojure but it's just too buggy.
      # The issue: when I include pkgs.clojure in nix.shell and try to run aliased commands out of my deps.edn,
      # it errors with any alias using the :extra-paths.
      # enableNixDirenvIntegration = true;
    };

    nnn = {
      enable = true;
      package = pkgs.nnn.override ({ withNerdIcons = true; });
    };


    # Just doesn't work. Getting permission denied error when it tries to read .config/gh
    # gh.enable = true;
  };
}
