{ pkgs, user, ... }: {

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
    configFile = {
      "mpv/mpv.conf".text = ''
        gapless-audio=no
        hwdec=auto-safe
        vo=gpu
        profile=gpu-hq
        gpu-context=wayland
      '';
      "electron-flags.conf".text = ''
        --enable-features=WaylandWindowDecorations
        --ozone-platform-hint=auto
      '';
      "starship.toml".source = ../../misc/starship.toml;
      "systemd/user.conf".text = ''
        [Manager]
        DefaultTimeoutStopSec=10
        DefaultTimeoutAbortSec=10
      '';
      "ranger/rc.conf".text = ''
        set preview_images true
        set preview_images_method iterm2
      '';
      "foot/foot.ini".text = ''
        [main]
        font=FiraMono Nerd Font:size=12
        shell=${pkgs.fish}/bin/fish
        dpi-aware=no

        [environment]
        COLORTERM=truecolor

        [mouse]
        hide-when-typing=yes

        [key-bindings]
        scrollback-up-page=none
        scrollback-down-page=none
        clipboard-copy=Control+c
        clipboard-paste=Control+v
        primary-paste=none
        search-start=none
        font-increase=Control+plus
        font-decrease=Control+minus
        font-reset=Control+equal
        spawn-terminal=none
        show-urls-launch=Control+Shift+u
        prompt-prev=none
        prompt-next=none


        [text-bindings]
        \x03 = Control+Shift+c
        \x16 = Control+Shift+v

        ${builtins.readFile ../../misc/foot-nord-theme.ini}
      '';
    };
    mimeApps = {
      # https://www.iana.org/assignments/media-types/media-types.xhtml
      enable = true;
      defaultApplications = {
        "application/http" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "inode/directory" = [ "nemo.desktop" ];
      };
    };
  };

  home = {
    stateVersion = "23.05";

    username = "${user}";
    homeDirectory = "/home/${user}";

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
      pkgs.tmux-snapshot
      pkgs.truecolor-test
      pkgs.rebuild
      pkgs.toggle-service
    ];

    sessionPath = [ "$HOME/.local/bin" ];

    sessionVariables = {
      SUCCESS_ALERT = "${pkgs.success-alert}";
      FAILURE_ALERT = "${pkgs.failure-alert}";
      BROWSER = "firefox";
      EDITOR = "nvim";
      PAGER = "less --chop-long-lines --RAW-CONTROL-CHARS";
      MANPAGER = "nvim +Man!";
      NNN_TRASH = "1";
      NNN_PLUG = "p:preview-tui;d:dragdrop";
      NNN_FCOLORS = "030304030705020801030301";
      NNN_FIFO = "/tmp/nnn.fifo";
      NNN_BATTHEME = "Nord";
      NNN_BATSTYLE = "plain";
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bat = {
      enable = true;
      config = {
        theme = "Nord";
        paging = "always";
        style = "plain";
      };
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
        "/.lsp"
        "/.clj-kondo"
      ];
      delta.enable = true;
      extraConfig = {
        core.editor = "nvim";
        init = { defaultBranch = "main"; };
        merge = { ff = "only"; };
        push.autoSetupRemote = true;
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

    nnn = {
      enable = true;
      package = pkgs.nnn.override { withNerdIcons = true; };
      plugins.src = (pkgs.fetchFromGitHub {
        owner = "jarun";
        repo = "nnn";
        rev = "v4.8";
        sha256 = "QbKW2wjhUNej3zoX18LdeUHqjNLYhEKyvPH2MXzp/iQ=";
      }) + "/plugins";
    };

    starship.enable = true;

    bash.enable = true;

  };
}
