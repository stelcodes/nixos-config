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
    configFile."mpv/mpv.conf".text = "gapless-audio=no";
  };

  home = {

    packages = [
      pkgs.htop
      pkgs.trash-cli
      pkgs.fd
      pkgs.neofetch
      pkgs.httpie
      pkgs.wget
      pkgs.ripgrep
      pkgs.tealdeer
      pkgs.unzip
      pkgs.restic
      pkgs.nix-prefetch-github
      pkgs.babashka
    ];

    sessionPath = [ "$HOME/.local/bin" ];

    file = {
      ".local/bin/view-rebuild-log" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          kitty nvim -R /tmp/nixos-rebuild-log
        '';
      };
      ".local/bin/view-nmtui" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          kitty nmtui
        '';
      };
      ".local/bin/rebuild" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          if test -f /tmp/nixos-rebuild-pid; then
            kill "$(</tmp/nixos-rebuild-pid)"
          fi
          echo $$ > /tmp/nixos-rebuild-pid
          echo "active" > /tmp/nixos-rebuild-status
          doas nixos-rebuild switch &> /tmp/nixos-rebuild-log
          if test $? -eq 0; then
            echo "success" > /tmp/nixos-rebuild-status
            cvlc --play-and-exit ${pkgs.success-alert}
          else
            echo "failure" > /tmp/nixos-rebuild-status
            cvlc --play-and-exit ${pkgs.failure-alert}
          fi
          rm /tmp/nixos-rebuild-pid
        '';
      };
    };
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

    fzf =
      let
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
      in
      {
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
