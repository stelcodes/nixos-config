{ pkgs, user, inputs, theme, ... }: {

  imports = [
    ../fish/home.nix
    ../neovim/home.nix
    ../tmux/home.nix
    inputs.nix-index-database.hmModules.nix-index
  ];

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
      "starship.toml".source = ../../misc/starship.toml;
      "systemd/user.conf".text = ''
        [Manager]
        DefaultTimeoutStopSec=10
        DefaultTimeoutAbortSec=10
      '';
    };
  };

  home = {

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
      inputs.nix-alien.packages.x86_64-linux.nix-alien
      pkgs.acpi
      pkgs.dua
      pkgs.croc
      pkgs.yt-dlp
      pkgs.check-newline
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
      NNN_FCOLORS = "030304030705020801030301";
      NNN_FIFO = "/tmp/nnn.fifo";
      NNN_BATTHEME = "base16";
      NNN_BATSTYLE = "plain";
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # Use "," command to run programs not currently installed with prebuilt nixpkgs index
    nix-index.enable = true;
    nix-index-database.comma.enable = true;

    bat = {
      enable = true;
      config = {
        theme = "base16";
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
      extraPackages = [
        # I could put some of these in graphical module, wait kind of like all of them actually
        pkgs.ffmpegthumbnailer
        pkgs.ffmpeg
        pkgs.imgcat
        pkgs.mediainfo
        pkgs.dragon
        pkgs.coreutils-full
        pkgs.gnused
        pkgs.gawk
        pkgs.findutils
        pkgs.fzf
        pkgs.viu
        pkgs.xdg-utils
      ];
      plugins = {
        mappings = {
          p = "preview-tui";
          d = "dragdrop";
          v = "-!env";
          e = "-enqueue";
          E = "-enqueue-all";
          n = "-nvim-clean";
        };
        src =
          let
            upstream = pkgs.fetchFromGitHub {
              owner = "jarun";
              repo = "nnn";
              rev = "v4.8";
              sha256 = "QbKW2wjhUNej3zoX18LdeUHqjNLYhEKyvPH2MXzp/iQ=";
            };
            enqueue = pkgs.writeShellApplication {
              name = "enqueue";
              runtimeInputs = [ pkgs.coreutils-full pkgs.audacious pkgs.playerctl ];
              text = builtins.readFile ./enqueue.sh;
            };
            enqueue-all = pkgs.writeShellApplication {
              name = "enqueue-all";
              runtimeInputs = [ pkgs.coreutils-full pkgs.audacious pkgs.playerctl ];
              text = builtins.readFile ./enqueue-all.sh;
            };
            nvim-clean = pkgs.writeShellApplication {
              name = "nvim-clean";
              runtimeInputs = [ pkgs.neovim-unwrapped pkgs.coreutils-full ];
              text = builtins.readFile ./nvim-clean.sh;
            };
          in
          pkgs.symlinkJoin {
            name = "nnn-plugins";
            paths = [ "${upstream}/plugins" "${enqueue}/bin" "${enqueue-all}/bin" "${nvim-clean}/bin" ];
          };
      };
    };

    starship.enable = true;

    bash.enable = true;

  };
}
