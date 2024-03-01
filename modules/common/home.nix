{ pkgs, lib, inputs, config, systemConfig, ... }: {

  imports = [
    ../fish/home.nix
    ../neovim/home.nix
    ../tmux/home.nix
    ../graphical/home.nix
    ../sway/home.nix
    ../audio/home.nix
    inputs.nix-index-database.hmModules.nix-index
    inputs.wayland-pipewire-idle-inhibit.homeModules.default
  ];

  options = {
    programs.nnn.plugins.scripts = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
  };

  config = {
    systemd.user = {
      settings.Manager.DefaultEnvironment = {
        PATH = "/run/current-system/sw/bin:/etc/profiles/per-user/${config.home.username}/bin";
      };
      startServices = true;
      services = {
        env-check = {
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.coreutils}/bin/env";
            Restart = "never";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };
    };

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
        # https://github.com/aristocratos/btop#configurability
        "btop/btop.conf".text = ''
          color_theme = "${systemConfig.theme.set.btop}"
          vim_keys = True
        '';
      };
    };

    home = {
      username = "${systemConfig.admin.username}";
      homeDirectory = "/home/${systemConfig.admin.username}";

      packages = [
        pkgs.btop
        pkgs.trash-cli
        pkgs.fd
        pkgs.neofetch
        pkgs.wget
        pkgs.ripgrep
        pkgs.tealdeer
        pkgs.unzip
        pkgs.truecolor-test
        pkgs.desktop-entries
        pkgs.rebuild
        pkgs.toggle-service
        pkgs.dua
        pkgs.vimv-rs
        pkgs.jq
        pkgs.fzf
        pkgs.exiftool
      ] ++ (lib.lists.optionals systemConfig.activities.coding [
        pkgs.nix-prefetch-github
        pkgs.check-newline
        pkgs.doctl
        pkgs.yt-dlp
        pkgs.croc
        pkgs.restic
        pkgs.gh
        inputs.nix-alien.packages.x86_64-linux.nix-alien
      ]);

      sessionVariables = {
        SUCCESS_ALERT = "${pkgs.success-alert}";
        FAILURE_ALERT = "${pkgs.failure-alert}";
        EDITOR = "nvim";
        PAGER = "less --chop-long-lines --RAW-CONTROL-CHARS";
        MANPAGER = "nvim +Man!";
        NNN_TRASH = "1";
        NNN_FCOLORS = "030304030705020801030301";
        NNN_BATTHEME = "base16";
        NNN_BATSTYLE = "plain";
        NNN_PISTOL = "1";
        BAT_THEME = "base16";
      };

      file = {
        ".hm-generation-source".source = ../..;
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
          "/result"
          "/target"
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

      direnv = {
        enable = systemConfig.activities.coding;
        nix-direnv.enable = true;
      };

      pistol = {
        enable = true;
        associations =
          let
            ffprobeBase = "sh: ffprobe -v quiet -print_format json -show_format -pretty %pistol-filename%";
            audioFilters = {
              "title" = ".tags.TITLE";
              "artist" = ".tags.ARTIST";
              "album" = ".tags.ALBUM";
              "album_artist" = ".tags.album_artist";
              "date" = ".tags.DATE";
              "duration" = ".duration";
              "size" = ".size";
              "bitrate" = ".bit_rate";
              "encoder" = ".tags.ENCODER";
              "comment" = ".tags.comment";
            };
            ffprobeWithoutFilters = ffprobeBase + " | jq -C .format";
            ffprobeWithFilters = filters: ffprobeBase + " | jq -C '.format | { " + (lib.foldlAttrs (acc: name: value: acc + "${name}: ${value}, ") "" filters) + " }'";
          in
          [
            # Must install ffmpeg for media previews
            { mime = "audio/*"; command = "exiftool --ExifTool* --Directory* --File* --Frame* --Block* --TotalSamples* --MD5* --Picture* --MusicBrainz* --Traktor* --Djuced* %pistol-filename%"; }
            { mime = "video/*"; command = "exiftool --ExifTool* --Directory* --File* --Frame* --Block* --TotalSamples* --MD5* %pistol-filename%"; }
            { mime = "image/*"; command = "exiftool --ExifTool* --Directory* --File* --Frame* --Block* --TotalSamples* --MD5* %pistol-filename%"; }
            { mime = "inode/directory"; command = "eza -la --color always %pistol-filename%"; }
            { mime = "application/epub+zip"; command = "bk --meta %pistol-filename%"; }
          ];
      };

      nnn = {
        enable = true;
        package = (pkgs.nnn.override { withNerdIcons = true; }).overrideAttrs (finalAttrs: previousAttrs: {
          patches = [ "${pkgs.nnn.src}/patches/gitstatus/mainline.diff" ];
        });
        extraPackages = [
          pkgs.coreutils-full
          pkgs.gnused
          pkgs.gawk
          pkgs.findutils
          pkgs.fzf
          pkgs.xdg-utils
        ];
        bookmarks = {
          m = "/run/media/${config.home.username}";
          M = "~/music";
          d = "~/downloads";
          D = "~/documents";
          v = "~/videos";
          t = "~/tmp";
          n = "~/nixos-config";
          c = "~/.config";
          l = "~/.local";
          w = "~/.wine/drive_c";
          h = "~";
          s = "~/sync";
        };
        plugins = {
          mappings = {
            t = "preview-tui"; # tui
            n = "!nvim*"; # nvim
            N = "nvim-clean";
            r = "rename-with-vimv"; # rename
            x = "!dua --stay-on-filesystem interactive*"; # trash
            p = "copy-with-rsync"; # paste
            P = "copy-with-rsync-include-list";
            c = "copy-relative-filenames"; # copy
            C = "copy-absolute-filenames";
            f = "fuzzy-files-cd"; # files
            F = "fuzzy-files-open";
            d = "fuzzy-directories-cd"; # directories
          };
          scripts = [
            (pkgs.writeShellApplication {
              name = "nvim-clean";
              runtimeInputs = [ pkgs.neovim-unwrapped pkgs.coreutils-full ];
              text = builtins.readFile ./nvim-clean.sh;
            })
            (pkgs.writeShellApplication {
              name = "copy-relative-filenames";
              runtimeInputs = [ pkgs.coreutils-full pkgs.wl-clipboard pkgs.libnotify ];
              text = ''
                # Copy relative filenames from hovered file or selection

                selection=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                notify() {
                  notify-send "nnn" "Path selection copied to clipboard"
                }

                clear_sel() {
                  if [ -s "$selection" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                if [ -s "$selection" ]; then
                  result=""
                  paths=""
                  IFS= readarray -d "" paths < <(cat "$selection")
                  for path in "''${paths[@]}"; do
                    printf -v result "%s%s\n" "$result" "$(basename "$path")"
                  done
                  wl-copy "$result" && clear_sel && notify
                elif [ -n "$1" ]; then
                  wl-copy "$(basename "$1")" && notify
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "copy-absolute-filenames";
              runtimeInputs = [ pkgs.coreutils-full pkgs.wl-clipboard pkgs.libnotify ];
              text = ''
                # Copy absolute filenames from hovered file or selection

                SEL=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                notify() {
                  notify-send "nnn" "Path selection copied to clipboard"
                }

                clear_sel() {
                  if [ -s "$SEL" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                if [ -s "$SEL" ]; then
                  wl-copy "$(printf "%s\n" "$(sed 's/\x0/\n/g' < "$SEL")")" && clear_sel && notify
                elif [ -n "$1" ]; then
                  wl-copy "$PWD/$1" && notify
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "rename-with-vimv";
              runtimeInputs = [ pkgs.vimv-rs ];
              text = ''
                # Rename files with vimv-rs

                SEL=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                clear_sel() {
                  if [ -s "$SEL" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                if [ -s "$SEL" ]; then
                  xargs --null vimv < "$SEL" && clear_sel
                else
                  vimv
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "copy-with-rsync";
              runtimeInputs = [ pkgs.rsync pkgs.findutils pkgs.coreutils-full ];
              text = ''
                # Copy files with rsync

                clear_sel() {
                  if [ -s "$SEL" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                SEL=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}
                if [ -s "$SEL" ]; then
                  echo "=========================================================================="
                  echo "SELECTIONS:"
                  while IFS= read -rd $'\0' ITEM || [ "$ITEM" ] ; do
                    WARNING=""
                    if [ -e "./$(basename "$ITEM")" ]; then
                      WARNING=" \033[0;33mWARNING: ALREADY EXISTS IN DEST\033[0m"
                    fi
                    echo -e "$ITEM$WARNING"
                  done < "$SEL"
                  echo
                  echo "DESTINATION:"
                  echo "$PWD"
                  echo
                  read -rp 'Are you sure? '
                  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
                    xargs --null -I {} rsync -rltxhv {} "$PWD" < "$SEL" && clear_sel
                  else
                    echo "Aborting operation..."
                  fi
                else
                  echo "A selection is required"
                fi
                echo
              '';
            })


            (pkgs.writeShellApplication {
              name = "copy-with-rsync-include-list";
              runtimeInputs = [ pkgs.rsync pkgs.findutils pkgs.coreutils-full ];
              text = ''
                # Copy files with rsync

                clear_sel() {
                  if [ -s "$SEL" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                TMPFILE="$(mktemp)"
                SEL=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}
                SRC=""

                if [ -s "$SEL" ]; then
                  echo "=========================================================================="
                  while IFS= read -rd $'\0' ITEM || [ "$ITEM" ] ; do
                    if [ -z "$SRC" ]; then
                      SRC="$ITEM"
                      if [ ! -d "$SRC" ]; then
                        printf "ERROR: First selection '%s' is not a directory" "$SRC"
                        exit 1
                      fi
                    else
                      if [[ "$ITEM" == "$SRC"* ]]; then
                        printf "%s\n" "''${ITEM:''${#SRC}}" >> "$TMPFILE"
                      else
                        printf "ERROR: '%s' is not in directory '%s'" "$ITEM" "$SRC"
                        exit 1
                      fi
                    fi
                  done < "$SEL"
                  echo "SOURCE:"
                  echo "$SRC"
                  echo
                  echo "FILES FROM:"
                  cat "$TMPFILE"
                  echo
                  echo "DESTINATION:"
                  echo "$PWD"
                  echo
                  read -rp 'Are you sure? '
                  if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
                    rsync -rltxhv --files-from="$TMPFILE" "$SRC" "$PWD" && clear_sel
                  else
                    echo "Aborting operation..."
                  fi
                else
                  echo "A selection is required"
                fi
                echo
              '';
            })

            (pkgs.writeShellApplication {
              name = "fuzzy-directories-cd";
              runtimeInputs = [ pkgs.fzf pkgs.fd pkgs.coreutils-full ];
              text = ''
                fzf_sel="$(fd --type directory 2>/dev/null | fzf)"
                if [ -d "$fzf_sel" ] && ! [ "$fzf_sel" = "." ]; then
                  printf "%s" "0c$PWD/$fzf_sel" > "$NNN_PIPE" # change directory
                fi
              '';
            })

            (pkgs.writeShellApplication {
              name = "fuzzy-directories-cd-from-selection";
              runtimeInputs = [ pkgs.fzf pkgs.fd pkgs.coreutils-full ];
              text = ''
                selection=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                if [ -s "$selection" ]; then
                  fzf_sel="$(xargs -0 fd --type directory < "$selection" 2>/dev/null | fzf)"
                else
                  fzf_sel="$(fd --type directory 2>/dev/null | fzf)"
                fi

                if [ -d "$fzf_sel" ] && ! [ "$fzf_sel" = "." ]; then
                  printf "%s" "-" > "$NNN_PIPE" # clear selection
                  printf "%s" "0c$PWD/$fzf_sel" > "$NNN_PIPE" # change directory
                fi
              '';
            })

            (pkgs.writeShellApplication {
              name = "fuzzy-files-open";
              runtimeInputs = [ pkgs.xdg-utils pkgs.fzf pkgs.fd pkgs.coreutils-full ];
              text = ''
                fzf_sel="$(fd --type file 2>/dev/null | fzf)"
                if [ -f "$fzf_sel" ]; then
                  xdg-open "$fzf_sel"
                fi
              '';
            })

            (pkgs.writeShellApplication {
              name = "fuzzy-files-cd";
              runtimeInputs = [ pkgs.fzf pkgs.fd pkgs.coreutils-full ];
              text = ''
                fzf_sel_dir="$(fd --type file 2>/dev/null | fzf | xargs -0 dirname)"
                if [ -d "$fzf_sel_dir" ] && ! [ "$fzf_sel_dir" = "." ]; then
                  printf "%s" "0c$PWD/$fzf_sel_dir" > "$NNN_PIPE"
                fi
              '';
            })

          ];
          src =
            pkgs.symlinkJoin {
              name = "nnn-plugins";
              paths = [ "${inputs.nnn-plugins}/plugins" ] ++ map (script: "${script}/bin") config.programs.nnn.plugins.scripts;
            };
        };
      };

      # I prefer having starship enabled via NixOS options because all users get the prompt, including root
      starship.enable = false;

      bash.enable = true;

    };
  };
}
