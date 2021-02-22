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

  systemd.extraConfig = ''
    DefaultTimoutStopSec=10s
  '';

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
    pulseaudio.enable = true;
    facetimehd.enable = true;
    bluetooth.enable = true;
    opengl.enable = true;
  };

  services = {
    # xserver = {
    #   enable = true;
    #   displayManager.defaultSession = "none+xmonad";
    #   windowManager = {
    #     xmonad = {
    #       enable = true;
    #       enableContribAndExtras = true;
    #       extraPackages = haskellPackages: [
    #         haskellPackages.xmonad-contrib
    #         haskellPackages.xmonad-extras
    #         haskellPackages.xmonad-wallpaper
    #         haskellPackages.xmonad
    #         haskellPackages.ghc
    #         haskellPackages.xmobar
    #         haskellPackages.xmonad
    #       ];
    #       config = ''
    #         import XMonad

    #         main = launch defaultConfig
    #             { modMask = mod4Mask -- Use Super instead of Alt
    #             , terminal = "alacritty"
    #             }
    #       '';
    #     };
    #   };
    #   # From stackoverflow 
    #   xkbOptions = "caps:escape";
    #   xkbVariant = "mac";
    #   exportConfiguration = true;
    #   # Configure keymap in X11
    #   layout = "us";
    #   # Enable touchpad support (enabled default in most desktopManager).
    #   libinput.enable = true;
    # };

    # logind = { killUserProcesses = true; };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable the OpenSSH daemon.
    # openssh.enable = true;
  };

  users = {
    mutableUsers = false;
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users = {
      stel = {
        home = "/home/stel";
        hashedPassword =
          "$6$xHvNROyNWizt5$CAewy9Y8Z3syC7BzvbkrLgu1VKe0laL4xVozcgFuB1Wh13KjVSnobZiCV/4It7BA926l22tO5x1dwukg0q6/H0";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "video"
        ]; # Enable ‘sudo’ for the user.
      };
    };
  };

  fonts.fontconfig = { enable = true; };
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    firefox
    mkpasswd
    gnome3.dconf-editor
  ];

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
    users.stel = { pkgs, ... }: {
      # Home Manager needs a bit of information about you and the
      # paths it should manage.
      nixpkgs.config.allowUnfree = true;

      wayland.windowManager.sway = {
        enable = true;
        config = {
          terminal = "alacritty -e tmux attach";
          modifier = "Mod4";
          bars = [];
          colors = {
            focused = {
              background = "#285577";
              border = "#4c7899";
              childBorder = "#a3be8c";
              indicator = "#2e9ef4";
              text = "#ffffff";
            };
          };
        };
        extraConfig = ''
          input "1452:657:Apple_Inc._Apple_Internal_Keyboard_/_Trackpad" {
            xkb_layout us
            xkb_variant mac
            xkb_options caps:escape
          }

          input type:touchpad {
            natural_scroll enabled
          }

          bar {
            swaybar_command waybar
          }

          bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
          bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
          bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
          bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
          bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
          bindsym XF86MonBrightnessUp exec brightnessctl set +5%
          bindsym XF86AudioPlay exec playerctl play-pause
          bindsym XF86AudioNext exec playerctl next
          bindsym XF86AudioPrev exec playerctl previous
          bindsym XF86KbdBrightnessUp exec brightnessctl --device='smc::kbd_backlight' set +10%
          bindsym XF86KbdBrightnessDown exec brightnessctl --device='smc::kbd_backlight' set 10%-
        '';
      };

      home = {
        username = "stel";
        homeDirectory = "/home/stel";

        # This value determines the Home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new Home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = "21.03";

        packages = [
          # process monitor
          pkgs.htop
          # fonts
          (pkgs.nerdfonts.override { fonts = [ "Noto" ]; })
          pkgs.font-awesome
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
          pkgs.python3
          pkgs.postgresql

          # Other package managers
          pkgs.rustup
          # Run this:
          # rustup toolchain install stable
          # cargo install <package>

          pkgs.clojure
          pkgs.nodejs
          pkgs.postgresql
          pkgs.nixfmt

          pkgs.nix-index

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

          #sway
          pkgs.swaylock
          pkgs.swayidle
          pkgs.dmenu
          pkgs.brightnessctl
          pkgs.playerctl
          pkgs.libinput
          pkgs.xorg.xev

          #math
          pkgs.rink

          #printing
          pkgs.hplip
          pkgs.evince # pdf viewer

          # video
          pkgs.youtube-dl

          pkgs.upower
          pkgs.dbus
        ];

        # I'm putting all manually installed executables into ~/.local/bin 
        sessionPath = [ "$HOME/.cargo/bin" "$HOME/go/bin" "$HOME/.local/bin" ];
        sessionVariables = { };
      };

      # dconf.settings = {
      #   "${gnomeKeys}" = {
      #     custom-keybindings = [
      #       "${gnomeKeys}/custom-keybindings/custom0"
      #     ];
      #   };
      #   "${gnomeKeys}/custom-keybindings/custom0" = {
      #     binding = "<Super>t";
      #     command = "alacritty";
      #     name = "open terminal";
      #   };
      # };

      programs = {

        # Let Home Manager install and manage itself.
        home-manager.enable = true;

        # Just doesn't work. Getting permission denied error when it tries to read .config/gh
        # gh.enable = true;

        waybar = {
          enable = true;
          settings = [{
            layer = "top";
            position = "bottom";
            height = 16;
            output = [ "eDP-1" ];
            modules-left = [ "sway/workspaces" "sway/mode" ];
            modules-center = [ ];
            modules-right = [ "battery" "clock" ];
            modules = {
              "sway/workspaces" = {
                disable-scroll = true;
                all-outputs = true;
              };
              "clock" = {
                  format-alt = "{:%a, %d. %b  %H:%M}";
                };
            };
          }];
        };

        go = {
          enable = true;

        };

        lsd = { enable = true; };

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
          '';
          shellAliases = {
            "nix-search" = "nix repl '<nixpkgs>'";
            "source-zsh" = "source $HOME/.config/zsh/.zshrc";
            "source-tmux" = "tmux source-file ~/.tmux.conf";
            "switch" =
              "sudo nixos-rebuild switch && source $HOME/.config/zsh/.zshrc";
            "hg" = "history | grep";
            "ls" = "${pkgs.lsd}/bin/lsd --color always -A";
            "lsl" = "${pkgs.lsd}/bin/lsd --color always -lA";
            "lst" = ''${pkgs.lsd}/bin/lsd --color always --tree -A -I ".git"'';
            "volume-max" = "pactl -- set-sink-volume 0 100%";
            "volume-half" = "pactl -- set-sink-volume 0 50%";
            "volume-mute" = "pactl -- set-sink-volume 0 0%";
            "keycode-listen" = "sudo libinput debug-events --show-keycodes";
          };
          plugins = let
            tmux-zsh-environment = {
              name = "tmux-zsh-environment";
              src = pkgs.fetchFromGitHub {
                owner = "stelcodes";
                repo = "tmux-zsh-environment";
                rev = "780eff5ac781cc4a1cc9f1bd21bac92f57e34e48";
                sha256 = "0k2b9hw1zjndrzs8xl10nyagzvhn2fkrcc89zzmcw4g7fdyw9w9q";
              };
            };
          in [ tmux-zsh-environment ];
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
            {
              plugin = suda-vim;
              config = "command! W SudaWrite";
            }
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
          ignores =
            [ "*Session.vim" "*.DS_Store" "*.swp" "*.direnv" "/direnv" ];
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
          extraConfig = ''
            set -ga terminal-overrides ',alacritty:Tc'
            # set -as terminal-overrides ',xterm*:sitm=\E[3m'

            # https://is.gd/8VKFEY
            set -g focus-events on

            # Switch windows
            bind -n M-h  previous-window
            bind -n M-l next-window
            bind M-a next-window

            # Kill active pane
            bind -n M-x kill-pane

            # Detach from session
            bind -n M-d detach

            # New window
            bind -n M-f new-window

            # See all windows in all sessions
            bind -n M-s choose-tree -s

            # Fixes tmux escape input lag, see https://git.io/JtIsn
            set -sg escape-time 10

            # Update environment
            set-option -g update-environment "PATH"
          '';
          plugins = [
            pkgs.tmuxPlugins.nord
            {
              plugin = pkgs.tmuxPlugins.resurrect;
              extraConfig = "set -g @resurrect-strategy-nvim 'session'";
            }
            {
              plugin = pkgs.tmuxPlugins.continuum;
              extraConfig = ''
                set -g @continuum-restore 'on'
                set -g @continuum-save-interval '5' # minutes
              '';
            }
            {
              plugin = pkgs.tmuxPlugins.fzf-tmux-url;
              extraConfig = "set -g @fzf-url-bind 'u'";
            }
            # {
            # 	plugin = tmuxPlugins.dracula;
            # 	extraConfig = ''
            # 		set -g @dracula-show-battery false
            # 		set -g @dracula-show-powerline true
            # 		set -g @dracula-refresh-rate 10 '';
            # }
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

        # Not supported for Mac:
        # firefox

      };

      xdg.configFile."alacritty/alacritty.yml".text = pkgs.lib.mkMerge [
        ''
          shell:
            program: ${pkgs.zsh}/bin/zsh''
        (builtins.readFile ./alacritty-base.yml)
        (builtins.readFile ./alacritty-nord.yml)
      ];

      xdg.configFile."clojure/deps.edn".text = ''
          {:aliases
            {:new
              {:extra-deps {seancorfield/clj-new {:mvn/version "1.1.243"}}
               :exec-fn clj-new/create
               :exec-args {:template "app"}}}}'';

    };
  };
}

