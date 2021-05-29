{ pkgs, config, ... }: {
  config = {

    boot.cleanTmpDir = true;

    # hosts
    networking.hosts = {
      "104.236.219.156" = [ "nube1" ];
      "167.99.122.78" = [ "morado1" ];
    };

    # Set your time zone.
    time.timeZone = "America/Detroit";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    console = {
      font = "Lat2-Terminus16";
      # keyMap = "us";
      useXkbConfig = true;
    };

    security = {
      doas = {
        enable = true;
        extraRules = [{
          users = [ "stel" ];
          keepEnv = true;
          noPass = true;
          # persist = true;
        }];
      };
      sudo.enable = false;
      acme = {
        email = "stel@stel.codes";
        acceptTerms = true;
      };
    };

    users = {
      mutableUsers = true;
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users = {
        stel = {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "jackaudio" "audio" ];
          shell = pkgs.zsh;
        };
      };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget

    environment.variables = {
      BROWSER = "firefox";
      EDITOR = "nvim";
    };

    environment.systemPackages = with pkgs; [
      zsh
      starship
      neovim
      git
      bat
      # process monitoring
      htop
      procs
      # cross platform trash bin
      trash-cli
      # alternative find, also used for fzf
      fd
      # system info
      neofetch
      # http client
      httpie
      # download stuff from the web
      wget
      # searching text
      ripgrep
      # documentaion
      tealdeer
      # archiving
      unzip
      # backups
      restic
      # ls replacement
      exa
      # make replacement
      just
      # math
      rink
      # nix
      nixfmt
      nix-prefetch-github
      # timeless db
      sqlite
      # for urlview tmux plugin
      urlview
    ];

    programs.zsh = {
      enable = true;
      shellAliases = {
        "nix-search" = "nix repl '<nixpkgs>'";
        "source-zsh" = "source $HOME/.config/zsh/.zshrc";
        "source-tmux" = "tmux source-file ~/.tmux.conf";
        "update" = "doas nix-channel --update";
        "switch" = "doas nixos-rebuild switch";
        "hg" = "history | grep";
        "wifi" = "nmtui";
        "vpn" = "doas protonvpn connect -f";
        "attach" = "tmux attach";
        "gui" = "exec sway";
        "absolutepath" = "realpath -e";
        "ls" = "exa";
        "grep" = "rg";
        "restic-backup-napi" =
          "restic -r /run/media/stel/Napi/restic-backups/ backup --files-from=/home/stel/config/misc/restic/include.txt --exclude-file=/home/stel/config/misc/restic/exclude.txt";
        "restic-mount-napi" =
          "restic -r /run/media/stel/Napi/restic-backups/ mount /home/stel/backups/Napi-restic";
        "restic-backup-mapache" =
          "restic -r /run/media/stel/Mapache/restic-backups/ backup --files-from=/home/stel/config/misc/restic/include.txt --exclude-file=/home/stel/config/misc/restic/exclude.txt";
        "restic-mount-mapache" =
          "restic -r /run/media/stel/Mapache/restic-backups/ mount /home/stel/backups/Mapache-restic";
        "pdf" = "evince-previewer";
        "play-latest-obs-recording" =
          "mpv $(ls /home/stel/videos/obs | sort --reverse | head -1)";
        # Creating this alias because there's a weird bug with the clj command producing this error on nube1:
        # rlwrap: error: Cannot execute BINDIR/clojure: No such file or directory
        "clj" = "clojure";
        "screenshot" =
          "slurp | grim -g - ~/pictures/screenshots/grim:$(date -Iseconds).png";
        "bat" = "bat --theme=base16";
      };
      promptInit = ''eval "$(starship init zsh)"'';
      autosuggestions = { enable = true; };
      ohMyZsh = {
        enable = true;
        plugins = [ "httpie" "colored-man-pages" ];
      };
    };

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      runtime."filetype.vim".source =
        /home/stel/config/modules/neovim/filetype.vim;
      configure = {
        customRC =
          builtins.readFile /home/stel/config/modules/neovim/extra-config.vim;
        packages.myVimPackage = let
          stel-paredit = pkgs.vimUtils.buildVimPlugin {
            pname = "stel-paredit";
            version = "1.0";
            src = pkgs.fetchFromGitHub {
              owner = "stelcodes";
              repo = "paredit";
              rev = "27d2ea61ac6117e9ba827bfccfbd14296c889c37";
              sha256 = "1bj5m1b4n2nnzvwbz0dhzg1alha2chbbdhfhl6rcngiprbdv0xi6";
            };
          };
        in with pkgs.vimPlugins; {
          start = [
            nerdtree
            vim-obsession
            vim-commentary
            vim-dispatch
            vim-projectionist
            vim-eunuch
            vim-fugitive
            vim-sensible
            vim-nix
            lightline-vim
            conjure
            vim-fish
            vim-css-color
            tabular
            vim-gitgutter
            vim-auto-save
            ale
            nord-vim
            stel-paredit
          ];
        };
      };
    };

    environment.etc = {
      gitconfig.text = ''
        [init]
          defaultBranch = "main"
        [merge]
          ff = "only"
        [user]
          email = "stel@stel.codes"
          name = "Stel Abrego"
        [core]
          excludesFile = /etc/gitignore
      '';
      gitignore.text = ''
        *Session.vim
        *.DS_Store
        *.swp
        *.direnv
        /direnv
        /local
        /node_modules
        *.jar
      '';
    };

    programs.tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      escapeTime = 10;
      keyMode = "vi";
      newSession = true;
      terminal = "screen-256color";
      extraConfig = let
        continuumSaveScript =
          "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh";
      in ''
        set-option -g prefix M-a

        set -ga terminal-overrides ',alacritty:Tc'

        # https://is.gd/8VKFEY
        set -g focus-events on

        # Custom Keybindings
        bind -n M-h previous-window
        bind -n M-l next-window
        bind -n M-x kill-pane
        bind -n M-d detach
        bind -n M-f new-window -c "#{pane_current_path}"
        bind -n M-s choose-tree -s
        bind -n M-c copy-mode
        bind -n M-r command-prompt 'rename-session %%'
        bind -n M-n command-prompt 'new-session'
        bind -n M-t source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

        # Fixes tmux escape input lag, see https://git.io/JtIsn
        set -sg escape-time 10

        # Update environment
        set -g update-environment "PATH"

        set -g status-style fg=white,bg=default
        set -g status-justify left
        set -g status-left ""
        # setting status right makes continuum fail! Apparently it uses the status to save itself? Crazy. https://git.io/JOXd9
        set -g status-right "#[fg=yellow,bg=default][#S] #[fg=default,bg=default]in #[fg=green,bg=default]#h#(${continuumSaveScript})"

        run-shell ${pkgs.tmuxPlugins.urlview.rtp}

        run-shell ${pkgs.tmuxPlugins.yank.rtp}

        set -g @resurrect-processes '"~bin/vim->vim -S"'
        run-shell ${pkgs.tmuxPlugins.resurrect.rtp}

        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '1' # minutes
        run-shell ${pkgs.tmuxPlugins.continuum.rtp}
      '';
    };

  };
}
