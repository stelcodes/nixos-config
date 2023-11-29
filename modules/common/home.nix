{ pkgs, lib, adminName, inputs, theme, config, ... }: {

  imports = [
    ../fish/home.nix
    ../neovim/home.nix
    ../tmux/home.nix
    inputs.nix-index-database.hmModules.nix-index
  ];

  options = {
    programs.nnn.plugins.scripts = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.package;
    };
  };

  config = {
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
        # https://github.com/aristocratos/btop#configurability
        "btop/btop.conf".text = ''
          color_theme = "${theme.btop}"
          vim_keys = True
        '';
      };
    };

    home = {
      username = "${adminName}";
      homeDirectory = "/home/${adminName}";

      packages = [
        pkgs.btop
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

      nnn = {
        enable = true;
        package = (pkgs.nnn.override { withNerdIcons = true; }).overrideAttrs (finalAttrs: previousAttrs: {
          patches = [ "${inputs.nnn-src}/patches/gitstatus/mainline.diff" ];
        });
        extraPackages = [
          pkgs.coreutils-full
          pkgs.gnused
          pkgs.gawk
          pkgs.findutils
          pkgs.fzf
          pkgs.viu
          pkgs.xdg-utils
        ];
        bookmarks = {
          m = "/run/media/${adminName}";
        };
        plugins = {
          mappings = {
            w = "preview-tui";
            e = "-!env";
            n = "-nvim-clean";
            r = "rename-with-vimv";
            x = "delete-with-dua";
            p = "copy-with-rsync";
            P = "copy-with-rsync-include-list";
          };
          scripts = [
            (pkgs.writeShellApplication {
              name = "nvim-clean";
              runtimeInputs = [ pkgs.neovim-unwrapped pkgs.coreutils-full ];
              text = builtins.readFile ./nvim-clean.sh;
            })
            (pkgs.writeShellApplication {
              name = "rename-with-vimv";
              runtimeInputs = [ pkgs.vimv-rs ];
              text = ''
                # Rename files with vimv-rs
                SEL=''${NNN_SEL:-''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.selection}
                if [ -s "$SEL" ]; then
                  xargs --null vimv < "$SEL"
                else
                  vimv
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "delete-with-dua";
              runtimeInputs = [ pkgs.dua ];
              text = "dua --stay-on-filesystem interactive";
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

          ];
          src =
            pkgs.symlinkJoin {
              name = "nnn-plugins";
              paths = [ "${inputs.nnn-src}/plugins" ] ++ map (script: "${script}/bin") config.programs.nnn.plugins.scripts;
            };
        };
      };

      # I prefer having starship enabled via NixOS options because all users get the prompt, including root
      starship.enable = false;

      bash.enable = true;

    };
  };
}
