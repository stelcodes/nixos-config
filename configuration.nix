# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # From https://github.com/NixOS/nixpkgs/issues/15162
  nixpkgs.config.allowUnfree = true;

  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #<home-manager/nixos>
    (import "${
        builtins.fetchTarball
        "https://github.com/rycee/home-manager/archive/master.tar.gz"
      }/nixos")
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "wl" ];
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    # resumeDevice = "/dev/sda2";
  };

  security = {
    pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
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
  };

  networking = {
    hostName = "azul"; # Define your hostname.
    networkmanager.enable = true;
    # networking.wireless.userControlled = true;
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    enableIPv6 = false;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlp3s0.useDHCP = false;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
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

  # Enable sound.
  sound.enable = true;

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull.override { jackaudioSupport = true; };
    };
    facetimehd.enable = true;
    bluetooth.enable = true;
    opengl.enable = true;
  };

  services = {
    # Enable CUPS to print documents.
    printing.enable = true;

    blueman.enable = true;
    gnome3.gnome-keyring.enable = true;

    postgresql = {
      enable = true;
      package = pkgs.postgresql_13;
      enableTCPIP = true;
      port = 5432;
      dataDir = "/data/postgres";
      # authentication = pkgs.lib.mkOverride 10 ''
      #   local all all trust
      #   host all all ::1/128 trust
      # '';
      authentication = "";
      ensureDatabases = [ "cuternews" "wtpof" ];
      ensureUsers = [
        {
          name = "stel";
          ensurePermissions = {
            "DATABASE cuternews" = "ALL PRIVILEGES";
            "DATABASE wtpof" = "ALL PRIVILEGES";
          };
        }
        {
          name = "wtpof";
          ensurePermissions = {
            "DATABASE wtpof" = "ALL PRIVILEGES";
          };
        }
      ];
      # extraPlugins = [ pkgs.postgresql_13.pkgs.postgis ];
    };

    # don’t shutdown when power button is short-pressed
    logind.extraConfig = "HandlePowerKey=ignore";

    # jack = {
    #   jackd = {
    #     enable = true;
    #     # from Arch Wiki https://is.gd/RXY6lR
    #     # session = ''
    #     #   jack_control start
    #     #   jack_control ds alsa
    #     #   jack_control dps device hw:HDA
    #     #   jack_control dps rate 48000
    #     #   jack_control dps nperiods 2
    #     #   jack_control dps period 64
    #     #   sleep 10
    #     #   a2j_control --ehw
    #     #   a2j_control --start
    #     #   sleep 10
    #     #   qjackctl &
    #     # '';
    #     session = "";
    #   };
    #   alsa.enable = false;
    #   loopback.enable = true;
    # };
  };

  users = {
    mutableUsers = true;
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      stel = {
        home = "/home/stel";
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "jackaudio" "audio" ];
        packages = [
          # process monitor
          pkgs.htop
          # fonts
          # cross platform trash bin
          pkgs.trash-cli
          # alternative find, also used for fzf
          pkgs.fd
          # system info
          pkgs.neofetch
          # zsh prompt
          pkgs.starship
          # http client
          pkgs.httpie
          # download stuff from the web
          pkgs.wget
          pkgs.ripgrep
          pkgs.tealdeer
          pkgs.unzip
          pkgs.restic
          pkgs.procs
          pkgs.exa

          # Programming Languages

          # (pkgs.python3.withPackages (py-pkgs: [py-pkgs.swaytools])) this would work but swaytools isn't in the nixos python modules
          pkgs.python39
          pkgs.python39Packages.pip
          # pip packages: swaytools

          # Other package managers
          pkgs.rustup
          # Run this:
          # rustup toolchain install stable
          # cargo install <package>

          pkgs.clojure
          pkgs.nodejs
          pkgs.just
          pkgs.sqlite

          pkgs.nixfmt
          pkgs.nix-index
          pkgs.nix-prefetch-github

          # Not supported for mac:
          pkgs.babashka
          pkgs.clj-kondo
          pkgs.tor-browser-bundle-bin
          pkgs.discord
          # proton vpn
          pkgs.protonvpn-cli
          pkgs.calibre
          pkgs.spotify

          #art
          pkgs.gimp
          pkgs.ardour

          #sway
          pkgs.swaylock
          pkgs.swayidle
          pkgs.dmenu
          pkgs.brightnessctl
          pkgs.playerctl
          pkgs.libinput
          pkgs.xorg.xev
          #dependency for swaytools (installed via pip install --user swaytools)
          pkgs.slurp
          pkgs.gnome3.nautilus
          pkgs.keepassxc
          pkgs.font-manager
          pkgs.gnome3.seahorse
          pkgs.wl-clipboard

          #math
          pkgs.rink

          #printing
          pkgs.hplip
          pkgs.evince # pdf viewer
          pkgs.pdfarranger

          # media
          pkgs.youtube-dl
          pkgs.shotcut
          pkgs.mpv-unwrapped
          # pkgs.qjackctl
          # pkgs.a2jmidid
          # pkgs.cadence

          pkgs.qbittorrent
          pkgs.firefox

          # pkgs.upower
          pkgs.dbus

          # music
          # this is a wrapper around spotify so sway can recognize container attributes properly
          pkgs.spotifywm

          # office
          pkgs.libreoffice

          #email
          pkgs.thunderbird
          pkgs.protonmail-bridge
        ];
      };
      wtpof = {
        description = "We The People Opportunity Farm";
        isSystemUser = true;
        home = "/home/wtpof";
        createHome = true;
        packages = [ pkgs.nodejs pkgs.sqlite ];
        shell = pkgs.bashInteractive;
      };
    };
  };

  fonts = {
    fontconfig = { enable = true; };
    fonts =
      [ (pkgs.nerdfonts.override { fonts = [ "Noto" ]; }) pkgs.font-awesome ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ zsh neovim ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  home-manager = {
    users.stel = { pkgs, config, ... }: {
      # Home Manager needs a bit of information about you and the
      # paths it should manage.
      nixpkgs.config.allowUnfree = true;

      wayland.windowManager.sway = {
        enable = true;
        config = {
          assigns = {
            "1:vibes" = [{ class = "^Spotify$"; }];
            "2:www" = [{ class = "^Firefox$"; }];
            "3:term" = [{ title = "^Alacritty$"; }];
            "4:art" = [ { class = "^Gimp$"; } { title = "Shotcut$"; } ];
            "5:mail" = [{ class = "^Thunderbird$"; }];
          };
          terminal = "alacritty";
          modifier = "Mod4";
          fonts = [ "NotoMono Nerd Font 8" ];
          bars = [ ];
          colors = {
            focused = {
              background = "#2e3440";
              border = "#2e3440";
              childBorder = "#8c738c";
              indicator = "#2e9ef4";
              text = "#eceff4";
            };
          };
          window = {
            hideEdgeBorders = "smart";
          };
          keybindings =
            let modifier = config.wayland.windowManager.sway.config.modifier;
            in pkgs.lib.mkOptionDefault {
              "${modifier}+tab" = "workspace next";
              "${modifier}+shift+tab" = "workspace prev";
            };
          keycodebindings = {
            # Use xev to get keycodes, libinput gives wrong codes for some reason
            "232" = "exec brightnessctl set 5%-"; # f1
            "233" = "exec brightnessctl set +5%"; # f2
            "128" = "layout tabbed"; # f3
            "212" = "layout stacked"; # f4
            "237" =
              "exec brightnessctl --device='smc::kbd_backlight' set 10%-"; # f5
            "238" =
              "exec brightnessctl --device='smc::kbd_backlight' set +10%"; # f6
            "173" = "exec playerctl previous"; # f7
            "172" = "exec playerctl play-pause"; # f8
            "171" = "exec playerctl next"; # f9
            "121" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle"; # f10
            "122" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%"; # f11
            "123" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%"; # f12
          };
          input = {
            "1452:657:Apple_Inc._Apple_Internal_Keyboard_/_Trackpad" = {
              xkb_layout = "us";
              xkb_variant = "mac";
              xkb_options = "caps:escape";
            };
            "type:touchpad" = { 
              natural_scroll = "enabled";
              dwt = "enabled";
              tap = "enabled";
              tap_button_map = "lrm";
            };
          };
          output = {
            "*" = { bg = "~/Pictures/wallpapers/pretty-nord.jpg fill"; };
          };
          startup = [
            { command = "exec alacritty"; }
            { command = "exec firefox"; }
            { command = "exec gimp"; }
            { command = "exec spotifywm"; }
            { command = "exec protonmail-bridge"; }
            {
              command = "exec thunderbird";
            }
            # This will lock your screen after 300 seconds of inactivity, then turn off
            # your displays after another 300 seconds, and turn your screens back on when
            # resumed. It will also lock your screen before your computer goes to sleep.
            {
              command = ''
                exec swayidle -w \
                timeout 300 'swaylock -f -c 000000' \
                timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
                before-sleep 'swaylock -f -c 000000'
              '';
            }
            {
              command = "sleep 7 && systemctl --user restart waybar";
              always = true;
            }
          ];
        };
      };

      home = {
        username = "stel";
        homeDirectory = "/home/stel";

        file = {
          ".clojure/deps.edn".source = ./deps.edn;
          ".npmrc".text = "prefix = \${HOME}/.npm-packages";
        };

        # This value determines the Home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new Home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = "21.03";


        # I'm putting all manually installed executables into ~/.local/bin 
        sessionPath = [
          "$HOME/.cargo/bin"
          "$HOME/go/bin"
          "$HOME/.local/bin"
          "$HOME/.npm-packages/bin"
        ];
        sessionVariables = { };
      };

      programs = {

        # Let Home Manager install and manage itself.
        home-manager.enable = true;

        # Just doesn't work. Getting permission denied error when it tries to read .config/gh
        # gh.enable = true;

        waybar = {
          enable = true;
          style = builtins.readFile ./waybar.css;
          systemd.enable = true;
          settings = [{
            layer = "top";
            position = "bottom";
            height = 20;
            output = [ "eDP-1" ];
            modules-left = [ "sway/workspaces" "sway/mode" ];
            modules-center = [ ];
            modules-right = [
              "cpu"
              "memory"
              "disk"
              "network"
              "backlight"
              "pulseaudio"
              "battery"
              "clock"
            ];
            modules = {
              "sway/workspaces" = {
                disable-scroll = true;
                all-outputs = true;
                format = "{name}";
                persistent_workspaces = {
                  "1:vibes" = [ ];
                  "2:www" = [ ];
                  "3:term" = [ ];
                  "4:art" = [ ];
                  "5:mail" = [ ];
                };
              };
              cpu = {
                interval = 10;
                format = "{} ";
              };
              memory = {
                interval = 30;
                format = "{} ";
              };
              disk = {
                interval = 30;
                format = "{percentage_used} ";
              };
              network = {
                # format = "{bandwidthDownBits}";
                max-length = 50;
                format-wifi = "{essid} {signalStrength} ";
              };
              pulseaudio = {
                format = "{volume} {icon}";
                format-bluetooth = "{volume} {icon} ";
                format-muted = "{volume} ";
                format-icons = { default = [ "" "" ]; };
                on-click = "pavucontrol";
              };
              clock = { format-alt = "{:%a, %d. %b  %H:%M}"; };
              battery = {
                format = "{capacity} {icon}";
                format-icons = [ "" "" "" "" "" ];
                max-length = 40;
              };
              backlight = {
                interval = 5;
                format = "{percent} {icon}";
                format-icons = [ "" "" ];
              };
            };
          }];
        };

        go = {
          enable = true;

        };

        direnv = {
          enable = true;
          # I wish I could get nix-shell to work with clojure but it's just too buggy.
          # The issue: when I include pkgs.clojure in nix.shell and try to run aliased commands out of my deps.edn,
          # it errors with any alias using the :extra-paths.
          # enableNixDirenvIntegration = true;
        };

        zsh = {
          enable = true;
          autocd = true;
          dotDir = ".config/zsh";
          enableAutosuggestions = true;
          dirHashes = { desktop = "$HOME/Desktop"; };
          initExtraFirst = ''
            source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
          '';
          initExtra = ''
            # Initialize starship prompt
            eval "$(starship init zsh)"

            # From https://is.gd/M2fmiv
            zstyle ':completion:*' menu select
            zmodload zsh/complist

            # use the vi navigation keys in menu completion
            bindkey -M menuselect 'h' vi-backward-char
            bindkey -M menuselect 'k' vi-up-line-or-history
            bindkey -M menuselect 'l' vi-forward-char
            bindkey -M menuselect 'j' vi-down-line-or-history

            # if [ "$TMUX" = "" ]; then tmux attach; fi
          '';
          shellAliases = {
            "nix-search" = "nix repl '<nixpkgs>'";
            "source-zsh" = "source $HOME/.config/zsh/.zshrc";
            "source-tmux" = "tmux source-file ~/.tmux.conf";
            "switch" = "doas nixos-rebuild switch";
            "hg" = "history | grep";
            "wifi" = "nmtui";
            "vpn" = "doas protonvpn connect -f";
            "attach" = "tmux attach -t '$1'";
            "volume-max" = "pactl -- set-sink-volume 0 100%";
            "volume-half" = "pactl -- set-sink-volume 0 50%";
            "volume-mute" = "pactl -- set-sink-volume 0 0%";
          };
          oh-my-zsh = {
            enable = true;
            plugins = [
              # docker completion
              "docker"
              # self explanatory
              "colored-man-pages"
              # completion + https command
              "httpie"
              # pp_json command
              "jsontools"
            ];
            # I like minimal, mortalscumbag, refined, steeef
            #theme = "mortalscumbag";
            extraConfig = ''
              bindkey '^[c' autosuggest-accept
            '';
          };
        };

        neovim = {
          enable = true;
          vimAlias = true;
          plugins = let

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

            suda-vim = pkgs.vimUtils.buildVimPlugin {
              pname = "suda.vim";
              version = "0.2.0";
              src = pkgs.fetchFromGitHub {
                owner = "lambdalisue";
                repo = "suda.vim";
                rev = "45f88d4f0699c054af775b82c87b93b439da0a22";
                sha256 = "0apf28b569qz4vik23jl0swka37qwmbxxiybfrksy7i1yaq6d38g";
              };
            };
          in [
            pkgs.vimPlugins.nerdtree
            pkgs.vimPlugins.vim-obsession
            pkgs.vimPlugins.vim-commentary
            pkgs.vimPlugins.vim-dispatch
            pkgs.vimPlugins.vim-projectionist
            pkgs.vimPlugins.vim-eunuch
            pkgs.vimPlugins.vim-fugitive
            pkgs.vimPlugins.vim-sensible
            pkgs.vimPlugins.vim-nix
            pkgs.vimPlugins.lightline-vim
            pkgs.vimPlugins.conjure
            pkgs.vimPlugins.vim-fish
            pkgs.vimPlugins.vim-css-color
            pkgs.vimPlugins.tabular
            pkgs.vimPlugins.vim-gitgutter
            # {
            #   plugin = suda-vim;
            #   config = "command! W SudaWrite";
            # }
            {
              plugin = pkgs.vimPlugins.vim-auto-save;
              config = "let g:auto_save = 1";
            }
            {
              plugin = pkgs.vimPlugins.ale;
              config = "let g:ale_linters = {'clojure': ['clj-kondo']}";
            }
            {
              plugin = pkgs.vimPlugins.nord-vim;
              config = "colorscheme nord";
            }
            {
              plugin = stel-paredit;
              config = "let g:paredit_smartjump=1";
            }
            # Waiting on markdown plugin to get added to nixpkgs
            # {
            #   plugin = markdown-preview;
            #   config = ''
            #     '';
            # }
          ];
          extraConfig = (builtins.readFile ./extra-config.vim) + ''

            set shell=${pkgs.zsh}/bin/zsh'';
        };

        bat = {
          enable = true;
          config = { theme = "base16"; };
        };

        alacritty = { enable = true; };

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
          ];
          extraConfig = { init = { defaultBranch = "main"; }; };
        };

        rtorrent = { enable = true; };

        tmux = {
          enable = true;
          baseIndex = 1;
          clock24 = true;
          keyMode = "vi";
          newSession = true;
          shell = "${pkgs.zsh}/bin/zsh";
          prefix = "M-a";
          # Set to "tmux-256color" normally, but theres this macOS bug https://git.io/JtLls
          terminal = "screen-256color";
          extraConfig = let
            continuumSaveScript = "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/scripts/continuum_save.sh";
          in ''
            set -ga terminal-overrides ',alacritty:Tc'
            # set -as terminal-overrides ',xterm*:sitm=\E[3m'

            # https://is.gd/8VKFEY
            set -g focus-events on

            # Custom Keybindings
            bind -n M-h  previous-window
            bind -n M-l next-window
            bind -n M-x kill-pane
            bind -n M-d detach
            bind -n M-f new-window
            bind -n M-s choose-tree -s
            bind -n M-c copy-mode

            # Fixes tmux escape input lag, see https://git.io/JtIsn
            set -sg escape-time 10

            # Update environment
            set -g update-environment "PATH"

            set -g status-style fg=white,bg=default
            set -g status-justify left
            set -g status-left ""
            # setting status right makes continuum fail! Apparently it uses the status to save itself? Crazy. https://git.io/JOXd9
            set -g status-right "[#S]#(${continuumSaveScript})"
          '';
          plugins = [
            # pkgs.tmuxPlugins.nord
            {
              plugin = pkgs.tmuxPlugins.fzf-tmux-url;
              extraConfig = "set -g @fzf-url-bind 'u'";
            }
            { plugin = pkgs.tmuxPlugins.yank; }
            {
              plugin = pkgs.tmuxPlugins.resurrect;
              extraConfig = "set -g @resurrect-strategy-nvim 'session'";
            }
            {
              plugin = pkgs.tmuxPlugins.continuum;
              extraConfig = ''
                set -g @continuum-restore 'on'
                set -g @continuum-save-interval '1' # minutes
              '';
            }
          ];
        };

        fzf = let
          fzfExcludes = [
            ".local"
            ".cache"
            "*photoslibrary"
            ".git"
            "node_modules"
            "Library"
            ".rustup"
            ".cargo"
            ".m2"
            ".bash_history"
          ];
          # string lib found here https://git.io/JtIua
          fzfExcludesString =
            pkgs.lib.concatMapStrings (glob: " --exclude '${glob}'")
            fzfExcludes;
        in {
          enable = true;
          defaultOptions = [ "--height 80%" "--reverse" ];
          defaultCommand = "fd --type f --hidden ${fzfExcludesString}";
          changeDirWidgetCommand = "fd --type d --hidden ${fzfExcludesString}";
          # I got tripped up because home.sessionVariables do NOT get updated with zsh sourcing.
          # They only get updated by restarting terminal, this is by design from the nix devs
          # See https://git.io/JtIuV
        };
      };

      xdg.configFile = {
        "alacritty/alacritty.yml".text = pkgs.lib.mkMerge [
          ''
            shell:
              program: ${pkgs.zsh}/bin/zsh''
          (builtins.readFile ./alacritty-base.yml)
          (builtins.readFile ./alacritty-nord.yml)
        ];

        "pulse/client.conf".text =
          "daemon-binary=/var/run/current-system/sw/bin/pulseaudio";

        "nvim/filetype.vim".source = ./filetype.vim;

        # I'm having a weird bug where clj -X:new gives an error about :exec-fn not being set even though it's set...
        # So I'm trying to put the deps.edn in the .config directory as well as the .clojure directory
        # I don't think this helped I had to use clj -X:new:clj-new/create
        "clojure/deps.edn".source = ./deps.edn;
      };

    };
  };
}

