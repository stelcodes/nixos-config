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
        show-urls-launch=Control+u
        prompt-prev=none
        prompt-next=none

        [text-bindings]
        \x03 = Control+Shift+c
        \x16 = Control+Shift+v

        [cursor]
        color = ${theme.bgx} ${theme.bg4x}

        [colors]
        foreground = ${theme.fgx}
        background = ${theme.bgx}
        selection-foreground = ${theme.bg4x}
        selection-background = ${theme.bg2x}
        regular0 = ${theme.bg3x}
        regular1 = ${theme.redx}
        regular2 = ${theme.greenx}
        regular3 = ${theme.yellowx}
        regular4 = ${theme.bluex}
        regular5 = ${theme.magentax}
        regular6 = ${theme.cyanx}
        regular7 = ${theme.fgx}
        bright0 = ${theme.bg3x}
        bright1 = ${theme.redx}
        bright2 = ${theme.greenx}
        bright3 = ${theme.yellowx}
        bright4 = ${theme.bluex}
        bright5 = ${theme.magentax}
        bright6 = ${theme.cyanx}
        bright7 = ${theme.fgx}
        dim0 = ${theme.bg3x}
        dim1 = ${theme.redx}
        dim2 = ${theme.greenx}
        dim3 = ${theme.yellowx}
        dim4 = ${theme.bluex}
        dim5 = ${theme.magentax}
        dim6 = ${theme.cyanx}
        dim7 = ${theme.fgx}
      '';
    };
    mimeApps = {
      # https://www.iana.org/assignments/media-types/media-types.xhtml
      # Check /run/current-system/sw/share/applications for .desktop entries
      # Take MimeType value from desktop entries and turn into nix code with this substitution:
      # s/\v([^;]+);/"\1" = [ "org.gnome.eog.desktop" ];\r/g
      enable = true;
      defaultApplications = {
        "application/http" = [ "firefox.desktop" ];
        "text/html" = [ "firefox.desktop" ];
        "application/pdf" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "inode/directory" = [ "thunar.desktop" ];
        "application/bzip2" = [ "org.gnome.FileRoller.desktop" ];
        "application/gzip" = [ "org.gnome.FileRoller.desktop" ];
        "application/vnd.android.package-archive" = [ "org.gnome.FileRoller.desktop" ];
        "application/vnd.ms-cab-compressed" = [ "org.gnome.FileRoller.desktop" ];
        "application/vnd.debian.binary-package" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-7z-compressed" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-7z-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-ace" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-alz" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-apple-diskimage" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-ar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-archive" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-arj" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-brotli" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-bzip-brotli-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-bzip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-bzip-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-bzip1" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-bzip1-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-cabinet" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-cd-image" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-compress" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-cpio" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-chrome-extension" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-deb" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-ear" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-ms-dos-executable" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-gtar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-gzip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-gzpostscript" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-java-archive" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lha" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lhz" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lrzip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lrzip-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lz4" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lzip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lzip-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lzma" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lzma-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lzop" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-lz4-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-ms-wim" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-rar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-rar-compressed" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-rpm" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-source-rpm" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-rzip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-rzip-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-tarz" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-tzo" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-stuffit" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-war" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-xar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-xz" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-xz-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-zip" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-zip-compressed" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-zstd-compressed-tar" = [ "org.gnome.FileRoller.desktop" ];
        "application/x-zoo" = [ "org.gnome.FileRoller.desktop" ];
        "application/zip" = [ "org.gnome.FileRoller.desktop" ];
        "application/zstd" = [ "org.gnome.FileRoller.desktop" ];
        "image/bmp" = [ "org.gnome.eog.desktop" ];
        "image/gif" = [ "org.gnome.eog.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/jpg" = [ "org.gnome.eog.desktop" ];
        "image/pjpeg" = [ "org.gnome.eog.desktop" ];
        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/tiff" = [ "org.gnome.eog.desktop" ];
        "image/webp" = [ "org.gnome.eog.desktop" ];
        "image/x-bmp" = [ "org.gnome.eog.desktop" ];
        "image/x-gray" = [ "org.gnome.eog.desktop" ];
        "image/x-icb" = [ "org.gnome.eog.desktop" ];
        "image/x-ico" = [ "org.gnome.eog.desktop" ];
        "image/x-png" = [ "org.gnome.eog.desktop" ];
        "image/x-portable-anymap" = [ "org.gnome.eog.desktop" ];
        "image/x-portable-bitmap" = [ "org.gnome.eog.desktop" ];
        "image/x-portable-graymap" = [ "org.gnome.eog.desktop" ];
        "image/x-portable-pixmap" = [ "org.gnome.eog.desktop" ];
        "image/x-xbitmap" = [ "org.gnome.eog.desktop" ];
        "image/x-xpixmap" = [ "org.gnome.eog.desktop" ];
        "image/x-pcx" = [ "org.gnome.eog.desktop" ];
        "image/svg+xml" = [ "org.gnome.eog.desktop" ];
        "image/svg+xml-compressed" = [ "org.gnome.eog.desktop" ];
        "image/vnd.wap.wbmp" = [ "org.gnome.eog.desktop" ];
        "image/x-icns" = [ "org.gnome.eog.desktop" ];
        "application/ogg" = [ "audacious.desktop" ];
        "application/x-cue" = [ "audacious.desktop" ];
        "application/x-ogg" = [ "audacious.desktop" ];
        "application/xspf+xml" = [ "audacious.desktop" ];
        "audio/aac" = [ "audacious.desktop" ];
        "audio/flac" = [ "audacious.desktop" ];
        "audio/midi" = [ "audacious.desktop" ];
        "audio/mp3" = [ "audacious.desktop" ];
        "audio/mp4" = [ "audacious.desktop" ];
        "audio/mpeg" = [ "audacious.desktop" ];
        "audio/mpegurl" = [ "audacious.desktop" ];
        "audio/ogg" = [ "audacious.desktop" ];
        "audio/prs.sid" = [ "audacious.desktop" ];
        "audio/wav" = [ "audacious.desktop" ];
        "audio/x-flac" = [ "audacious.desktop" ];
        "audio/x-it" = [ "audacious.desktop" ];
        "audio/x-mod" = [ "audacious.desktop" ];
        "audio/x-mp3" = [ "audacious.desktop" ];
        "audio/x-mpeg" = [ "audacious.desktop" ];
        "audio/x-mpegurl" = [ "audacious.desktop" ];
        "audio/x-ms-asx" = [ "audacious.desktop" ];
        "audio/x-ms-wma" = [ "audacious.desktop" ];
        "audio/x-musepack" = [ "audacious.desktop" ];
        "audio/x-s3m" = [ "audacious.desktop" ];
        "audio/x-scpls" = [ "audacious.desktop" ];
        "audio/x-stm" = [ "audacious.desktop" ];
        "audio/x-vorbis+ogg" = [ "audacious.desktop" ];
        "audio/x-wav" = [ "audacious.desktop" ];
        "audio/x-wavpack" = [ "audacious.desktop" ];
        "audio/x-xm" = [ "audacious.desktop" ];
        "x-content/audio-cdda" = [ "audacious.desktop" ];
        "text/markdown" = [ "neovim.desktop" ];
        "text/plain" = [ "neovim.desktop" ];
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
      inputs.nix-alien.packages.x86_64-linux.nix-alien
      pkgs.acpi
      pkgs.dua
      pkgs.croc
      pkgs.yt-dlp
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
          in
          pkgs.symlinkJoin {
            name = "nnn-plugins";
            paths = [ "${upstream}/plugins" "${enqueue}/bin" "${enqueue-all}/bin" ];
          };
      };
    };

    starship.enable = true;

    bash.enable = true;

  };
}
