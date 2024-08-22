{ pkgs, lib, inputs, config, ... }: {

  imports = [
    ./options.nix
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

    news.display = "silent";

    systemd.user = lib.mkIf pkgs.stdenv.isLinux {
      settings.Manager.DefaultEnvironment = {
        PATH = "/run/current-system/sw/bin:/etc/profiles/per-user/${config.home.username}/bin";
      };
      startServices = true;
      services = {
        env-check = {
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.coreutils}/bin/env";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };
    };

    xdg = {
      userDirs = lib.mkIf pkgs.stdenv.isLinux {
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
          color_theme = "${config.theme.set.btop}"
          vim_keys = True
        '';
      };
    };

    home = {
      username = lib.mkDefault "${config.admin.username}";
      homeDirectory = lib.mkDefault "/home/${config.admin.username}";

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
        pkgs.dua
        pkgs.mmv-go
        pkgs.jq
        pkgs.exiftool
        # pkgs.unrar
        pkgs.p7zip
      ] ++ (lib.lists.optionals pkgs.stdenv.isLinux [
        pkgs.desktop-entries
        pkgs.toggle-service
        inputs.nix-alien.packages.${pkgs.system}.nix-alien
      ]) ++ (lib.lists.optionals config.activities.coding [
        pkgs.nix-prefetch-github
        pkgs.nixpkgs-fmt
        pkgs.check-newline
        pkgs.doctl
        pkgs.yt-dlp
        pkgs.croc
        pkgs.restic
        pkgs.gh
      ]);

      sessionVariables = {
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
        ".ExifTool_config".source = ../../misc/exiftool-config.pl;
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
          "/dist"
        ];
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

      fzf.enable = true;

      direnv = {
        enable = config.activities.coding;
        nix-direnv.enable = true;
      };

      pistol = {
        enable = true;
        associations = [
          { mime = "audio/*"; command = "exiftool -S -title -duration -artist -album -albumartist -tracknumber -track -date* -year -catalog -label -publisher -genre -samplesize -bitspersample -samplerate -audiobitrate -flacbitrate -picturemimetype -mimetype -comment %pistol-filename%"; }
          { mime = "video/*"; command = "exiftool -S -title -duration -date* -videoframerate -imagewidth -imageheight -mimetype -description %pistol-filename%"; }
          { mime = "image/*"; command = "exiftool -S -imagesize -megapixels -mimetype %pistol-filename%"; }
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
        bookmarks =
          if pkgs.stdenv.isLinux then {
            m = "/run/media";
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
          } else {
            m = "/Volumes";
            M = "~/music";
            d = "~/Downloads";
            D = "~/Documents";
            v = "~/Videos";
            t = "~/tmp";
            n = "~/nixos-config";
            c = "~/.config";
            l = "~/.local";
            h = "~";
            s = "~/sync";
          };
        plugins = {
          mappings = {
            t = "preview-tui"; # tui
            n = "!nvim*"; # nvim
            N = "nvim-clean";
            r = "rename-with-mmv";
            x = "!dua --stay-on-filesystem interactive*"; # trash
            p = "copy-with-rsync"; # paste
            P = "copy-with-rsync-include-list";
            c = "copy-relative-filenames"; # copy
            C = "copy-absolute-filenames";
            f = "fuzzy-files-cd"; # files
            F = "fuzzy-files-open";
            d = "fuzzy-directories-cd"; # directories
            z = "unzipper";
            l = "create-symlinks";
          };
          scripts = let copyCommand = if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"; in [
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
                  ${copyCommand} "$result" && clear_sel && notify
                elif [ -n "$1" ]; then
                  ${copyCommand} "$(basename "$1")" && notify
                fi
              '';
            })

            (pkgs.writeShellApplication {
              name = "create-symlinks";
              runtimeInputs = [ pkgs.coreutils-full pkgs.wl-clipboard pkgs.libnotify ];
              text = ''
                # Create relative or absolute symlinks from selection

                selection=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                clear_sel() {
                  if [ -s "$selection" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                fail_prompt() {
                  if [ "$1" ]; then
                    read -rp "$1..."
                  else
                    read -rp "Aborting operation..."
                  fi
                  exit 1
                }

                if [ -s "$selection" ]; then

                  printf "\n=========================================================================\n"
                  printf "CREATING SYMLINKS\n\nSELECTIONS:\n"
                  abort=0
                  while IFS= read -rd $'\0' item || [ "$item" ] ; do
                    warning=""
                    if ! [ -e "$item" ]; then
                      warning="\033[0;33mWARNING: SOURCE DOES NOT EXIST\033[0m"
                      abort=1
                    elif [ -e "./$(basename "$item")" ]; then
                      warning="\033[0;33mWARNING: PATH ALREADY EXISTS IN DEST\033[0m"
                      abort=1
                    fi
                    printf "%s %b\n" "$item" "$warning"
                  done < "$selection"
                  printf "\nDESTINATION:\n%s\n\n" "$PWD"
                  if [ "$abort" = 1 ]; then
                    fail_prompt
                  fi
                  flags="-s"
                  read -rp 'Relative or absolute? (r/a) '
                  if [ "$REPLY" = "r" ]; then
                    flags="-sr"
                  elif [ "$REPLY" = "a" ]; then
                    flags="-s"
                  else
                    fail_prompt
                  fi
                  printf "\nCommand: ln %s\n\n" "$flags"
                  read -rp 'Are you sure? (y/n) '
                  if [ "$REPLY" = "y" ]; then
                    if xargs --null -I {} ln "$flags" {} "$PWD" < "$selection"; then
                      clear_sel
                      read -rp "Links created successfully!"
                    else
                      fail_prompt "Command failed"
                    fi
                  else
                    fail_prompt
                  fi
                else
                  fail_prompt "A selection is required"
                fi
                echo
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
                  ${copyCommand} "$(printf "%s\n" "$(sed 's/\x0/\n/g' < "$SEL")")" && clear_sel && notify
                elif [ -n "$1" ]; then
                  ${copyCommand} "$PWD/$1" && notify
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "rename-with-mmv";
              runtimeInputs = [ pkgs.coreutils-full pkgs.mmv-go ];
              text = ''
                # Copy relative filenames from hovered file or selection

                selection=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                notify() {
                  notify-send "nnn" "Rename successful"
                }

                clear_sel() {
                  if [ -s "$selection" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                if [ -s "$selection" ]; then
                  temp="$(mktemp)"
                  paths=""
                  IFS= readarray -d "" paths < <(cat "$selection")
                  for path in "''${paths[@]}"; do
                    basename="$(basename "$path")"
                    if [ -e "$PWD/$basename" ]; then
                      printf "%s\0" "$basename" >> "$temp"
                    else
                      read -rp 'Some of the selected files are not in the PWD, aborting...'
                      exit 1
                    fi
                  done
                  xargs --null mmv -- < "$temp" && rm "$temp" && clear_sel && notify
                elif [ -n "$1" ]; then
                  mmv -- "$(basename "$1")" && notify
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
              name = "unzipper";
              runtimeInputs = [ pkgs.coreutils-full pkgs.wl-clipboard pkgs.libnotify ];
              text = ''
                # Unzips archives

                selection=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}

                clear_sel() {
                  if [ -s "$selection" ] && [ -p "$NNN_PIPE" ]; then
                      printf "-" > "$NNN_PIPE"
                  fi
                }

                extract() {
                  path="$1"
                  filename="$(basename "$1")"
                  if [ -f "$path" ]; then
                    dest="$PWD/''${filename%.*}"
                    while [ -d "$dest" ]; do
                      dest="$dest-"
                    done
                    type="$(xdg-mime query filetype "$path")"
                    if [ "$type" = "application/zip" ] && ! [ -d "$dest" ]; then
                      unzip "$path" -d "$dest"
                    fi
                  fi
                }

                if [ -s "$selection" ]; then
                  paths=""
                  IFS= readarray -d "" paths < <(cat "$selection")
                  for path in "''${paths[@]}"; do
                    extract "$path"
                  done
                  clear_sel
                elif [ -n "$1" ] && [ -f "$1" ]; then
                  extract "$1"
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
