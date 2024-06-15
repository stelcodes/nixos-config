{ pkgs, config, systemConfig, inputs, lib, ... }:
let
  theme = systemConfig.theme.set;
in
{
  config = lib.mkIf systemConfig.profile.graphical {
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
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    home = {
      sessionVariables = {
        GTK_THEME = theme.gtkThemeName; # For gnome calculator and nautilus on sway
      };
      pointerCursor = {
        package = theme.cursorThemePackage;
        name = theme.cursorThemeName;
        size = 32;
        gtk.enable = true;
      };
      packages = [
        # System tooling
        pkgs.gnome.gnome-disk-utility
        pkgs.keepassxc
        # Media tooling
        pkgs.pavucontrol
        pkgs.mpv
        pkgs.audacious
        pkgs.gnome.eog
        pkgs.qalculate-gtk
        pkgs.helvum # better looking than qpwgraph
        pkgs.gnome.gnome-weather
      ];
    };

    qt = {
      # Necessary for keepassxc, qpwgrapgh, etc to theme correctly
      enable = true;
      platformTheme.name = "gtk";
      style.name = "gtk2";
    };

    xdg = {
      desktopEntries = {
        neovim = {
          name = "Neovim";
          genericName = "Text Editor";
          exec =
            let
              app = pkgs.writeShellScript "neovim-terminal" ''
                # Killing foot from sway results in non-zero exit code which triggers
                # xdg-mime to use next valid entry, so we must always exit successfully
                if [ "$SWAYSOCK" ]; then
                  foot -- nvim "$1" || true
                else
                  gnome-terminal -- nvim "$1" || true
                fi
              '';
            in
            "${app} %U";
          terminal = false;
          categories = [ "Utility" "TextEditor" ];
          mimeType = [ "text/markdown" "text/plain" "text/javascript" ];
        };
        nnn = {
          name = "nnn";
          genericName = "Text Editor";
          exec =
            let
              app = pkgs.writeShellScript "nnn-terminal" ''
                # Killing foot from sway results in non-zero exit code which triggers
                # xdg-mime to use next valid entry, so we must always exit successfully
                foot --app-id nnn -- fish -c "nnn '$1'" || true
              '';
            in
            "${app} %U";
          terminal = false;
          categories = [ "Utility" ];
          mimeType = [ "text/markdown" "text/plain" "text/javascript" ];
        };
      };

      configFile = {
        "mpv/mpv.conf".text = ''
          gapless-audio=no
          sub-auto=all
          osd-on-seek=msg-bar
          # vo=dmabuf-wayland
          hwdec=auto-safe
          demuxer-max-bytes=2048MiB
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
              color: ${theme.magenta};
          }
          .gajim-incoming-nickname {
              color: ${theme.yellow};
          }
          .gajim-url {
              color: ${theme.blue};
          }
          .gajim-status-online {
              color: ${theme.green};
          }
          .gajim-status-away {
              color: ${theme.red};
          }
        '';
        "swappy/config".text = ''
          [Default]
          save_dir=$XDG_PICTURES_DIR/screenshots
          save_filename_format=swappy-%FT%X.png
          show_panel=false
          line_size=5
          text_size=20
          text_font=sans-serif
          paint_mode=brush
          early_exit=true
          fill_shape=false
        '';
        "rofimoji.rc".text = ''
          action = copy
          selector = wofi
          files = [emojis]
          skin-tone = neutral
        '';

      } // (if theme ? configFile then theme.configFile else { });

      mimeApps = {
        # https://www.iana.org/assignments/media-types/media-types.xhtml
        # Check /run/current-system/sw/share/applications for .desktop entries
        # Take MimeType value from desktop entries and turn into nix code with this substitution:
        # s/\v([^;]+);/"\1" = [ "org.gnome.eog.desktop" ];\r/g
        enable = true;
        defaultApplications = {
          "application/http" = [ "firefox.desktop" ];
          "text/html" = [ "firefox.desktop" ];
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
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
          "audio/vnd.wave" = [ "audacious.desktop" ];
          "audio/x-wavpack" = [ "audacious.desktop" ];
          "audio/x-xm" = [ "audacious.desktop" ];
          "audio/x-opus+ogg" = [ "audacious.desktop" ];
          "audio/x-aiff" = [ "audacious.desktop" ];
          "x-content/audio-cdda" = [ "audacious.desktop" ];
          "text/markdown" = [ "neovim.desktop" ];
          "text/plain" = [ "neovim.desktop" ];
          "application/x-zerosize" = [ "neovim.desktop" ]; # empty files
          "video/vnd.avi" = [ "mpv.desktop" ];
          "video/mkv" = [ "mpv.desktop" ];
          # "application/x-mobipocket-ebook" = [ "org.pwmt.zathura.desktop" ];
          "application/epub+zip" = [ "org.pwmt.zathura.desktop" ];
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
          "application/oxps" = [ "org.pwmt.zathura.desktop" ];
          "application/x-fictionbook" = [ "org.pwmt.zathura.desktop" ];
          "inode/directory" = [ "nnn.desktop" ];
          "x-scheme-handler/obsidian" = [ "obsidian.desktop" ];
        };
      };

      dataFile = {
        "audacious/internet-radio-stations.audpl".source = ../../misc/internet-radio-stations.audpl;
      };
    };

    systemd.user.services = {
      audacious = {
        Unit = {
          Description = "audacious music player";
        };
        Service = {
          ExecStart = lib.getExe pkgs.audacious;
          ExecStartPost = "-${pkgs.sway}/bin/swaymsg for_window [app_id=audacious] move scratchpad";
          Restart = "on-failure";
        };
      };
      pomo-notify = {
        Unit = {
          Description = "pomo.sh notify daemon";
        };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.pomo}/bin/pomo notify";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
      nixos-rebuild = {
        Service = {
          Type = "exec";
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "nixos-rebuild-exec-start";
            runtimeInputs = [ pkgs.coreutils-full pkgs.nixos-rebuild pkgs.systemd pkgs.mpv ];
            text = ''
              notify_success() {
                notify-send "NixOS rebuild successful"
                { mpv ${pkgs.success-alert} || true; } &
                sleep 5 && kill -9 "$!"
              }
              notify_failure() {
                notify-send --urgency=critical "NixOS rebuild failed"
                { mpv ${pkgs.failure-alert} || true; } &
                sleep 5 && kill -9 "$!"
              }
              if systemctl start nixos-rebuild.service; then
                while systemctl -q is-active nixos-rebuild.service; do
                  sleep 1
                done
                if systemctl -q is-failed nixos-rebuild.service; then
                  notify_failure
                else
                  notify_success
                fi
              else
                notify_failure
              fi
            '';
          });
        };
      };
    };

    programs = {
      zathura = {
        enable = true;
        options = {
          default-fg = theme.fg;
          default-bg = theme.bg;
          statusbar-bg = theme.bg1;
          statusbar-fg = theme.fg;
        };
      };
      nnn = {
        extraPackages = [
          pkgs.xdragon
        ];
        plugins = {
          mappings = {
            D = "dragdrop-simple";
            a = "queue-audio";
            A = "copy-current-song";
            i = "-!&eog ."; # image viewer
          };
          scripts = [
            (pkgs.writeShellApplication {
              name = "queue-audio";
              runtimeInputs = [ pkgs.coreutils-full pkgs.audacious ];
              text = ''
                # Enqueues the selection or the hovered file if nothing is selected and ensures playback
                # Try to start audacious service to create totally independent process
                systemctl --user start audacious.service || true
                selection=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                queue_audio() {
                  audio="$1"
                  if test -f "$audio" && xdg-mime query filetype "$1" | grep -q "audio/"; then
                    if audtool --current-playlist-name | grep -q 'Now Playing' && audtool --playback-status | grep -q "playing"; then
                      flag="--enqueue"
                    else
                      flag="--enqueue-to-temp"
                    fi
                    audacious "$flag" "$audio"
                  fi
                }

                if [ -s "$selection" ]; then
                  paths=""
                  IFS= readarray -d "" paths < <(cat "$selection")
                  for path in "''${paths[@]}"; do
                    queue_audio "$path"
                  done &
                  # Clear selection
                  if [ -s "$selection" ] && [ -p "$NNN_PIPE" ]; then
                    printf "-" > "$NNN_PIPE"
                  fi
                elif [ -f "$1" ]; then
                  queue_audio "$1" &
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "queue-audio-reset";
              runtimeInputs = [ pkgs.coreutils-full pkgs.audacious ];
              text = ''
                # Enqueues the selection or the hovered file if nothing is selected and ensures playback
                # Try to start audacious service to create totally independent process
                systemctl --user start audacious.service || true

                if audtool --current-playlist-name 2>&1 | grep -q 'Now Playing'; then
                  audtool --playlist-clear
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "copy-current-song";
              runtimeInputs = [ pkgs.coreutils-full pkgs.audacious ];
              text = ''
                song="$(audtool --current-song-filename)"
                if [ -f "$song" ]; then
                  cp -n "$song" "$PWD"
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "dragdrop-simple";
              runtimeInputs = [ pkgs.coreutils-full pkgs.gnused pkgs.xdragon ];
              text = ''
                selection=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                if [ -s "$selection" ]; then
                  TMPFILE="$(mktemp)"
                  cat "$selection" > "$TMPFILE"
                  xargs -0 dragon < "$TMPFILE" &
                  rm "$TMPFILE"
                  # Clear selection
                  if [ -s "$selection" ] && [ -p "$NNN_PIPE" ]; then
                    printf "-" > "$NNN_PIPE"
                  fi
                else
                  if [ -n "$1" ] && [ -e "$1" ]; then
                    dragon "$1" &
                  fi
                fi
              '';
            })
          ];
        };
      };
    };

    # dconf dump /org/cinnamon/ | dconf2nix | nvim -R
    dconf.settings =
      with lib.hm.gvariant;
      let bind = x: mkArray type.string [ x ];
      in
      {
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu:///system" ];
          uris = [ "qemu:///system" ];
        };

        "com/github/johnfactotum/Foliate/view" = {
          bg-color = theme.bg1;
          fg-color = theme.fg;
          font = "FiraMono Nerd Font 16";
          invert = false;
          layout = "single";
          link-color = theme.cyan;
          prefer-dark-theme = true;
        };
        "org/gnome/desktop/wm/preferences" = {
          button-layout = "appmenu:close"; # Only show close button
        };
        "org/gnome/terminal/legacy" = {
          default-show-menubar = false;
        };

        "org/gnome/terminal/legacy/keybindings" = {
          copy = "<Primary>c";
          paste = "<Primary>v";
        };

        "org/gnome/terminal/legacy/profiles:" = {
          # Put IDs of other profiles if you have some already.
          list = [ "903204a8-2d64-461c-a67d-4fbd5654c266" ];

          # Set the default profile to it.
          default = "903204a8-2d64-461c-a67d-4fbd5654c266";
        };

        "org/gnome/terminal/legacy/profiles:/:903204a8-2d64-461c-a67d-4fbd5654c266" = {
          background-color = theme.bg;
          bold-color = theme.fg;
          bold-color-same-as-fg = true;
          cursor-background-color = theme.bg4;
          cursor-colors-set = true;
          cursor-foreground-color = theme.bg;
          foreground-color = theme.fg;
          highlight-background-color = theme.bg2;
          highlight-colors-set = true;
          highlight-foreground-color = theme.bg4;
          palette = [
            theme.bg3
            theme.red
            theme.green
            theme.yellow
            theme.blue
            theme.magenta
            theme.cyan
            theme.fg
            theme.bg3
            theme.red
            theme.green
            theme.yellow
            theme.blue
            theme.magenta
            theme.cyan
            theme.fg
          ];
          use-theme-background = false;
          use-theme-colors = false;
          use-theme-transparency = false;
          use-transparent-background = false;
          visible-name = theme.name;
          custom-command = "sh -c 'tmux attach || tmux new-session -s config -c $HOME/nixos-config; fish'";
          font = "FiraMono Nerd Font 14";
          scrollbar-policy = "never";
        };
      };

  };

}
