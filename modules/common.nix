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

  };
}
