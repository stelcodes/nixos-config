{ pkgs, inputs, lib, theme, system, ... }: {

  imports = [
    ../sway/home.nix
  ];

  gtk = {
    enable = true;
    font = {
      name = "FiraMono Nerd Font";
      size = 10;
    };
    theme = {
      name = theme.gtkThemeName;
      package = theme.gtkThemePackage;
    };
    iconTheme = {
      name = theme.iconThemeName;
      package = theme.iconThemePackage;
    };
    # gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  home = {
    sessionVariables = {
      # For gnome calculator, probably nautilus too
      GTK_THEME = theme.gtkThemeName;
      # Wayland-specific stuff
      SDL_VIDEODRIVER = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      _JAVA_AWT_WM_NONREPARENTING = 1;
      MOZ_ENABLE_WAYLAND = 1;
      NIXOS_OZONE_WL = 1;
      GDK_DPI_SCALE = -1;
    };
    pointerCursor = {
      package = theme.cursorThemePackage;
      name = theme.cursorThemeName;
      # Sway seems unaffected by this size and defaults to 24
      size = 24;
      gtk.enable = true;
    };
    packages = [
      pkgs.calibre
      pkgs.gimp-with-plugins
      pkgs.qbittorrent
      # pkgs.ungoogled-chromium
      pkgs.chromium
      pkgs.gnome.gnome-disk-utility
      pkgs.spotify
      pkgs.libimobiledevice # For iphone hotspot tethering
      pkgs.obsidian
      pkgs.pavucontrol
      pkgs.tor-browser-bundle-bin # tor-browser not working 4/16/23
      pkgs.vlc
      pkgs.mpv
      pkgs.appimage-run
      pkgs.signal-desktop
      pkgs.gnome-feeds
      pkgs.gnome.dconf-editor
      pkgs.jellyfin-media-player
      pkgs.cycle-pulse-sink
      pkgs.cycle-sway-scale
      pkgs.qalculate-gtk
      pkgs.swayimg
      pkgs.gnome.eog
      pkgs.gajim
      pkgs.qpwgraph
      pkgs.audacious # Use QT_QPA_PLATFORM=xcb to adjust plugin windows (Wayland QT issues)
      inputs.manix.packages.${system}.manix
    ];
  };

  qt = {
    # Necessary for keepassxc, qpwgrapgh, etc to theme correctly
    enable = true;
    platformTheme = "gtk";
    style.name = "gtk2";
  };

  xdg.desktopEntries = {
    neovim = {
      name = "Neovim";
      genericName = "Text Editor";
      exec = let app = pkgs.writeShellScript "neovim-inside-foot" ''
        # Killing foot from sway results in non-zero exit code which triggers
        # xdg-mime to use next valid entry, so we must always exit successfully
        ${pkgs.foot}/bin/foot nvim "$1" || true
      ''; in "${app} %U";
      terminal = false;
      categories = [ "Utility" "TextEditor" ];
      mimeType = [ "text/markdown" "text/plain" "text/javascript" ];
    };
  };

  xdg.configFile = {
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
      show-urls-launch=Control+slash
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
    # https://wiki.archlinux.org/title/Dolphin#Mismatched_folder_view_background_colors
    kdeglobals.text = ''
      [Colors:View]
      BackgroundNormal=${theme.bg}
    '';
    "wofi/config".text = "allow_images=true";
    "wofi/style.css".source = ../../misc/wofi.css;
    "pomo.cfg" = {
      onChange = ''
        ${pkgs.systemd}/bin/systemctl --user restart pomo-notify.service
      '';
      source = pkgs.writeShellScript "pomo-cfg" ''
        # This file gets sourced by pomo.sh at startup
        # I'm only caring about linux atm
        function lock_screen {
          if ${pkgs.procps}/bin/pgrep sway 2>&1 > /dev/null; then
            echo "Sway detected"
            # Only lock if pomo is still running
            test -f "$HOME/.local/share/pomo" && ${pkgs.swaylock}/bin/swaylock
            # Only restart pomo if pomo is still running
            test -f "$HOME/.local/share/pomo" && ${pkgs.pomo}/bin/pomo start
          fi
        }

        function custom_notify {
            # send_msg is defined in the pomo.sh source
            block_type=$1
            if [[ $block_type -eq 0 ]]; then
                echo "End of work period"
                send_msg 'End of a work period. Locking Screen!'
                ${pkgs.playerctl}/bin/playerctl --all-players pause
                ${pkgs.mpv}/bin/mpv ${pkgs.pomo-alert} || sleep 10
                lock_screen &
            elif [[ $block_type -eq 1 ]]; then
                echo "End of break period"
                send_msg 'End of a break period. Time for work!'
                ${pkgs.mpv}/bin/mpv ${pkgs.pomo-alert}
            else
                echo "Unknown block type"
                exit 1
            fi
        }
        POMO_MSG_CALLBACK="custom_notify"
        POMO_WORK_TIME=30
        POMO_BREAK_TIME=5
      '';
    };
    "gajim/theme/nord.css".text = ''
      .gajim-outgoing-nickname {
          color: rgb(180, 142, 173)
      }
      .gajim-incoming-nickname {
          color: rgb(235, 203, 139)
      }
      .gajim-url {
          color: rgb(94, 129, 172)
      }
      .gajim-status-online {
          color: rgb(163, 190, 140)
      }
      .gajim-status-away {
          color: rgb(191, 97, 106)
      }
    '';

  };

  xdg.mimeApps = {
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

  systemd.user.services.pomo-notify = {
    Unit = {
      Description = "pomo.sh notify daemon";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.pomo}/bin/pomo notify";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs = {
    nnn = {
      extraPackages = [
        pkgs.ffmpeg
        pkgs.ffmpegthumbnailer
        pkgs.dragon
        pkgs.mediainfo
      ];
      plugins = {
        mappings = {
          d = "dragdrop";
          e = "-enqueue";
          E = "-enqueue-all";
        };
        scripts = [
          (pkgs.writeShellApplication {
            name = "enqueue";
            runtimeInputs = [ pkgs.coreutils-full pkgs.audacious pkgs.playerctl ];
            text = builtins.readFile ./enqueue.sh;
          })
          (pkgs.writeShellApplication {
            name = "enqueue-all";
            runtimeInputs = [ pkgs.coreutils-full pkgs.audacious pkgs.playerctl ];
            text = builtins.readFile ./enqueue-all.sh;
          })

        ];
      };
    };
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

}
