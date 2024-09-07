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
        "btop/themes/catppuccin_macchiato.theme".source = "${inputs.catppuccin-btop}/themes/catppuccin_macchiato.theme";
      };
    };

    home = {
      username = lib.mkDefault "${config.admin.username}";
      homeDirectory = lib.mkDefault "/home/${config.admin.username}";

      packages = [
        pkgs.btop
        pkgs.trash-cli
        pkgs.fd
        pkgs.fastfetch
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

      zoxide.enable = true;

      yazi = {
        enable = true;
        package = pkgs.unstable.yazi;
        enableFishIntegration = true;
        shellWrapperName = "y";

        # Defaults: https://github.com/sxyazi/yazi/tree/main/yazi-config/preset

        settings = {
          plugin.prepend_fetchers = [
            # https://github.com/yazi-rs/plugins/tree/main/git.yazi#setup
            { id = "git"; name = "*"; run = "git"; }
            { id = "git"; name = "*/"; run = "git"; }
          ];
          opener.play = [
            { run = "umpv \"$@\""; orphan = true; for = "unix"; }
          ];
        };

        flavors = let f = inputs.yazi-flavors; in {
          catppuccin-frappe = "${f}/catppuccin-frappe.yazi";
        };

        theme.flavor.use = "catppuccin-frappe";

        plugins = let p = inputs.yazi-plugins; in {
          chmod = "${p}/chmod.yazi";
          full-border = "${p}/full-border.yazi";
          max-preview = "${p}/max-preview.yazi";
          git = "${p}/git.yazi";
          starship = "${inputs.starship-yazi}";
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
              run = "shell ${pkgs.fish}/bin/fish --block --confirm";
              desc = "Open shell here";
            }
            {
              on = "q";
              run = "close";
              desc = "Close the current tab, or quit if it is last tab";
            }
          ];
        };
      };

      # I prefer having starship enabled via NixOS options because all users get the prompt, including root
      starship.enable = false;

      bash.enable = true;

    };
  };
}
