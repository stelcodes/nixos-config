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

  config = {

    news.display = "silent";

    systemd.user = lib.mkIf pkgs.stdenv.isLinux {
      settings.Manager = {
        DefaultEnvironment.PATH = "/run/current-system/sw/bin:/etc/profiles/per-user/${config.home.username}/bin";
        DefaultTimeoutStopSec = 10;
        DefaultTimeoutAbortSec = 10;
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

    xdg.userDirs = lib.mkIf pkgs.stdenv.isLinux {
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

    home = {
      username = lib.mkDefault "${config.admin.username}";
      homeDirectory = lib.mkDefault "/home/${config.admin.username}";

      packages = [
        pkgs.trash-cli
        pkgs.fd
        pkgs.fastfetch
        pkgs.wget
        pkgs.ripgrep
        pkgs.unzip
        pkgs.truecolor-test
        pkgs.dua
        pkgs.jq
        pkgs.exiftool
        pkgs.tmux-startup
        # pkgs.unrar
        pkgs.p7zip
        pkgs.mediainfo # for yazi
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
        pkgs.git-backdate
        pkgs.devflake
      ]);

      sessionVariables = {
        EDITOR = "nvim";
        PAGER = "less --chop-long-lines --RAW-CONTROL-CHARS";
        MANPAGER = "nvim +Man!";
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

      btop = {
        enable = true;
        settings = {
          color_theme = config.theme.set.btop;
          vim_keys = true;
        };
      };

      git = {
        enable = true;
        userName = "Stel Clementine";
        userEmail = "dev@stelclementine.com";
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
          "/out"
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

      tealdeer = {
        enable = true;
        settings.updates.auto_update = true; # Uses cache for 30 days
      };

      zoxide.enable = true;

      yazi = {
        enable = true;
        package = pkgs.unstable.yazi;
        shellWrapperName = "y";
        # Defaults: https://github.com/sxyazi/yazi/tree/main/yazi-config/preset
        settings = {
          manager = {
            show_hidden = false;
            sort_by = "modified";
            sort_dir_first = true;
            sort_reverse = true;
          };
          plugin.prepend_fetchers = [
            # https://github.com/yazi-rs/plugins/tree/main/git.yazi#setup
            { id = "git"; name = "*"; run = "git"; }
            { id = "git"; name = "*/"; run = "git"; }
          ];
          opener = {
            play = lib.mkIf config.profile.graphical [
              # mpv-unify script from mpv package prevents simultaneous playback
              { desc = "Play"; run = "${pkgs.mpv-unify}/bin/mpv-unify \"$@\""; orphan = true; for = "unix"; }
            ];
            dj = lib.mkIf (config.profile.graphical && config.activities.djing) [
              { desc = "Queue"; run = "${pkgs.mpv-unify}/bin/mpv-unify --queue \"$@\""; orphan = true; for = "unix"; }
              { desc = "Rekordbox"; run = "${pkgs.rekordbox-add}/bin/rekordbox-add \"$@\""; block = true; for = "unix"; }
              { desc = "Convert audio"; run = "${pkgs.convert-audio}/bin/convert-audio \"$1\""; block = true; for = "unix"; }
            ];
          };
          # file -bL --mime-type <file>
          open.prepend_rules = [
            { mime = "inode/directory"; use = "open"; }
            { mime = "audio/*"; use = [ "play" "reveal" ] ++ (lib.optionals config.activities.djing [ "dj" ]); }
          ];
        };
        plugins =
          let
            p = inputs.yazi-plugins;
            mkYaziPlugin = (initLua:
              "${(pkgs.writeTextDir "plugin/init.lua" initLua)}/plugin"
            );
          in
          {
            chmod = "${p}/chmod.yazi";
            full-border = "${p}/full-border.yazi";
            max-preview = "${p}/max-preview.yazi";
            git = "${p}/git.yazi";
            starship = "${inputs.starship-yazi}";
            smart-enter = (mkYaziPlugin /* lua */ ''
              return {
                entry = function()
                  local h = cx.active.current.hovered
                  ya.manager_emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
                end,
              }
            '');
          };
        initLua = /* lua */ ''
          require("starship"):setup()
          require("git"):setup()
        '';
        keymap = {
          manager.prepend_keymap = [
            {
              on = "T";
              run = "plugin --sync max-preview";
              desc = "Maximize or restore the preview pane";
            }
            {
              on = [ "c" "m" ];
              run = "plugin chmod";
              desc = "Chmod on selected files";
            }
            {
              on = "!";
              run = "shell \"$SHELL\" --block --confirm";
              desc = "Open shell here";
            }
            {
              on = "q";
              run = "close";
              desc = "Close the current tab, or quit if it is last tab";
            }
            {
              on = "<Enter>";
              run = "plugin --sync smart-enter";
              desc = "Enter the directory instead of editing";
            }
            # Bookmarks
            { on = [ "'" "h" ]; run = "cd ~"; desc = "home"; }
            { on = [ "'" "n" ]; run = "cd /nix/store"; desc = "nix-store"; }
            { on = [ "'" "c" ]; run = "cd ~/.config/nixflake"; desc = "nix-config"; }
            { on = [ "'" "C" ]; run = "cd ~/.config"; desc = "config"; }
            { on = [ "'" "l" ]; run = "cd ~/.local"; desc = "local"; }
            { on = [ "'" "t" ]; run = "cd ~/tmp"; desc = "tmp-home"; }
            { on = [ "'" "T" ]; run = "cd /tmp"; desc = "tmp"; }
            { on = [ "'" "d" ]; run = "cd ~/downloads"; desc = "downloads"; }
            { on = [ "'" "m" ]; run = "cd ~/music"; desc = "music"; }
            { on = [ "'" "r" ]; run = "cd ~/music/dj-tools/rekordbox"; desc = "rekordbox"; }
          ] ++ lib.optionals pkgs.stdenv.isDarwin [
            { on = [ "'" "v" ]; run = "cd /Volumes"; desc = "volumes"; }
            { on = [ "'" "i" ]; run = "cd '~/Library/Mobile Documents/com~apple~CloudDocs'"; desc = "icloud"; }
          ];
        };
      };

      starship = {
        enable = true;
        settings = builtins.fromTOML (builtins.readFile ../../misc/starship.toml);
      };

      bash.enable = true;

      zsh = {
        enable = true;
        enableCompletion = true;
        enableVteIntegration = true;
        autocd = true;
        autosuggestion.enable = true;
        cdpath = [ ];
        defaultKeymap = "viins";
        dotDir = ".config/zsh";
        history = {
          append = false;
          extended = true;
          ignorePatterns = [ "rm *" "pkill *" ];
          path = "${config.xdg.dataHome}/zsh/zsh_history";
          save = 10000;
          share = true;
        };
        historySubstringSearch.enable = true;
        # Interactive shells
        initExtra = /* sh */ ''
          export SHELL="${pkgs.zsh}/bin/zsh"
          # Force PATH to contain unique values, existing duplicates get removed upon insert
          typeset -U path PATH
          # Make sure the Nix environment is sourced, this script is idempotent
          NIX_SETUP_SCRIPT="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
          if [ -e "$NIX_SETUP_SCRIPT" ]; then
            source "$NIX_SETUP_SCRIPT"
          fi
          # If terminal is kitty, use kitten to automatically install kitty terminfo on remote host when ssh'ing
          if [ "$TERM" = "xterm-kitty" ]; then
            alias ssh="kitty +kitten ssh"
          fi
          if [ "$(uname)" = "Darwin" ]; then # If on MacOS...
            # Append homebrew to PATH when necessary
            if [ -e /opt/homebrew ]; then
              path+=(/opt/homebrew/bin /opt/homebrew/sbin)
            fi
            # Append local/bin to PATH if it exists
            if [ -e "$HOME/.local/bin" ]; then
              path+=("$HOME/.local/bin")
            fi
            # Fix comma falling back to 'nixpkgs' channel when NIX_PATH not set (MacOS)
            if [ ! -v NIX_PATH ]; then
              export NIX_PATH='nixpkgs=flake:${inputs.nixpkgs}'
            fi
          fi

          function copy() { ${if pkgs.stdenv.isDarwin then "pbcopy" else "wl-copy"} }
          function paste() { ${if pkgs.stdenv.isDarwin then "pbpaste" else "wl-paste"} }
          ${builtins.readFile ./zvm-clipboard.sh}
        '';
        plugins = [
          {
            # Interactive git commands
            name = "forgit";
            src = pkgs.zsh-forgit;
            file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
          }
          {
            # Makes nix-shell automatically use zsh
            name = "zsh-nix-shell";
            src = pkgs.zsh-nix-shell;
            file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
          }
          {
            # Better vi mode, default one is buggy
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
          {
            # Awesome fzf tab completion
            name = "zsh-fzf-tab";
            src = pkgs.zsh-fzf-tab;
            file = "share/fzf-tab/fzf-tab.plugin.zsh";
          }
          {
            # Fuzzy history search
            name = "zsh-fzf-history-search";
            src = pkgs.zsh-fzf-history-search;
            file = "share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh";
          }
        ];
        sessionVariables = {
          CLICOLOR = 1; # For GNU ls to have colored output
          ZVM_LINE_INIT_MODE = "i"; # For vi-mode, start new prompts in insert mode
        };
        shellAliases = {
          t = "tmux-startup";
        };
        syntaxHighlighting.enable = true;
        zprof.enable = false; # Enable to debug startup time
        zsh-abbr = {
          enable = true;
          abbreviations = rec {
            ll = "ls -l";
            la = "ls -A";
            rm = "rm -i";
            mv = "mv -n";
            r = "rsync -rltxhv"; # use --delete-delay when necessary
            gs = "git status";
            gl = "git log";
            glf = "git log --pretty=format:'%C(yellow)%h%C(reset) %C(blue)%an%C(reset) %C(cyan)%cr%C(reset) %s %C(green)%d%C(reset)' --graph";
            config = "cd ~/.config/nixflake; nvim";
            d = "dua --stay-on-filesystem interactive";
            ssh-new-key = "ssh-keygen -t ed25519";
            date-sortable = "date +%Y-%m-%dT%H:%M:%S%Z"; # ISO 8601 date format with local timezone
            date-sortable-utc = "date -u +%Y-%m-%dT%H:%M:%S%Z"; # ISO 8601 date format with UTC timezone
            dl-base = "yt-dlp --embed-metadata --embed-thumbnail --progress --download-archive ./yt-dlp-archive.txt --user-agent 'Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0'";
            dl-video = "${dl-base} --embed-subs --sub-langs 'en' --embed-chapters --sponsorblock-mark 'default' --sponsorblock-remove 'sponsor' --remux-video 'mkv'";
            dl-video-yt = "${dl-video} --no-playlist --output '%(uploader_id,uploader)s/%(upload_date)s - %(uploader_id,uploader)s - %(title)s [%(id)s].%(ext)s'";
            yt = dl-video-yt;
            dl-video-yt-playlist = "${dl-video} --output '%(uploader_id,uploader)s - %(playlist)s/%(playlist_index).3d - %(upload_date)s - %(uploader_id,uploader)s - %(title)s [%(id)s].%(ext)s'";
            dl-video-1080 = "${dl-video} --format 'bestvideo[height<=1080]+bestaudio'";
            dl-video-1080-yt-playlist = "${dl-video-yt-playlist} --format 'bestvideo[height<=1080]+bestaudio'";
            # console.log(Array.from(document.querySelectorAll('li.music-grid-item a')).map(el => el.href).join("\n")) -> copy paste to file -> -a <filename>
            dl-audio-bc = "${dl-base} --format 'flac' --output '%(album,track,title|Unknown Album)s - %(track_number|00).2d - %(artist,uploader|Unknown Artist)s - %(track,title,webpage_url)s.%(ext)s'";
            dl-audio-yt = "${dl-base} --format 'bestaudio[acodec=opus]' --extract-audio";
            dl-yarn = "${dl-base} --extract-audio --output \"$HOME/music/samples/yarn/$(read).%(ext)s\"";
            noansi = "sed \"s,\\x1B\\[[0-9;]*[a-zA-Z],,g\"";
            loggy = " |& tee /tmp/loggy-$(${date-sortable}).log";
            network-test = "ping -c 1 -W 5 8.8.8.8";
            rebuild = lib.mkDefault "sudo nixos-rebuild switch --flake \"$HOME/.config/nixflake#\"";
            nix-repl-flake = "nix repl --expr \"(builtins.getFlake (toString $HOME/.config/nixflake)).nixosConfigurations.$hostname\"";
            nix-pkg-size = "nix path-info --closure-size --human-readable --recursive";
            nix-shell-nixpkgs = "nix shell --file .";
            nix-shell-default = "nix shell --impure --include nixpkgs=flake:nixpkgs --expr 'with import <nixpkgs> {}; { default = callPackage ./default.nix {}; }' default";
            nix-dependency = "nix-store --query --referrers /nix/store/";
            nix-bigstuff = "nix path-info -rS /run/current-system | sort -nk2";
            nix-why = "nix why-depends /run/current-system /nix/store/";
            caddy-server = "echo 'http://localhost:3030' && caddy file-server --listen :3030 --root";
            gists = "gh gist view";
          } // lib.optionalAttrs pkgs.stdenv.isLinux {
            sc = "systemctl";
            scu = "systemctl --user";
            jc = "journalctl -exf --unit"; # Using --unit for better completion
            jcu = "journalctl --user -exf --unit"; # Using --unit for better completion
            u = "udisksctl";
            rebuild_ = "systemctl start --user nixos-rebuild.service";
            sway = "exec systemd-cat --identifier=sway sway";
            swaytree = "swaymsg -t get_tree | nvim -R";
            swayinputs = "swaymsg -t get_inputs | nvim -R";
            swayoutputs = "swaymsg -t get_outputs | nvim -R";
            play = "audacious --enqueue-to-temp";
          };
        };
      };

    };
  };
}
