{ pkgs, lib, config, inputs, user, theme, hostName, system, ... }: {

  imports = [
    ../vpn
    inputs.agenix.nixosModules.default
  ];

  config = {
    boot.tmp.cleanOnBoot = true;

    # Enable networking
    networking = {
      hostName = hostName;
      networkmanager.enable = true;
      hosts = {
        "127.0.0.1" = [ "lh" ];
      };
    };

    # Set your time zone.
    time.timeZone = "America/Los_Angeles";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    console = {
      useXkbConfig = true;
      colors = with theme; [
        bgx
        redx
        greenx
        yellowx
        bluex
        magentax
        cyanx
        fgx
        bg1x
        redx
        greenx
        yellowx
        bluex
        magentax
        cyanx
        fgx
      ];
    };

    security.doas.enable = true;
    security.doas.extraRules = [{
      users = [ user ];
      keepEnv = true;
      noPass = true;
      # persist = true;
    }];
    # security.sudo.enable = false;
    # security.acme.email = "stel@stel.codes";
    # security.acme.acceptTerms = true;

    users = {
      mutableUsers = true;
      groups = {
        multimedia = { };
      };
      # Don't forget to set a password with ‘passwd’.
      users = {
        ${user} = {
          initialPassword = "password";
          isNormalUser = true;
          # https://wiki.archlinux.org/title/Users_and_groups#Group_list
          extraGroups = [ "networkmanager" "wheel" "tty" "dialout" "audio" "video" "cdrom" "multimedia" ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
          ];
          shell = pkgs.fish;
        };
      };
    };

    programs = {
      fish.enable = true;
      nix-ld.enable = true;
    };

    environment.systemPackages = [
      pkgs.vim
      pkgs.neovim
      pkgs.bat
      pkgs.btop
      pkgs.trash-cli
      pkgs.fd
      pkgs.ripgrep
      pkgs.tealdeer
      pkgs.unzip
      pkgs.git
      pkgs.wireguard-tools
      inputs.agenix.packages.${system}.default
    ];

    services = {

      # Nice to have, required for gnome-disks to work
      udisks2.enable = true;

      logind = {
        lidSwitch = "suspend-then-hibernate";
        extraConfig = ''
          # Don’t shutdown when power button is short-pressed
          HandlePowerKey=hibernate
          InhibitDelayMaxSec=10
        '';
      };

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

    };

    nixpkgs = {
      config = {
        allowInsecure = true;
        allowUnfree = true;
      };
      overlays = [
        (self: super: {
          success-alert = super.fetchurl {
            # https://freesound.org/people/martcraft/sounds/651624/
            url = "https://cdn.freesound.org/previews/651/651624_14258856-lq.mp3";
            sha256 = "urNwmGEG2YJsKOtqh69n9VHdj9wSV0UPYEQ3caEAF2c=";
          };
          failure-alert = super.fetchurl {
            # https://freesound.org/people/martcraft/sounds/651625/
            url = "https://cdn.freesound.org/previews/651/651625_14258856-lq.mp3";
            sha256 = "XAEJAts+KUNVRCFLXlGYPIJ06q4EjdT39G0AsXGbT2M=";
          };
          pomo-alert = super.fetchurl {
            # https://freesound.org/people/dersinnsspace/sounds/421829/
            url = "https://cdn.freesound.org/previews/421/421829_8224400-lq.mp3";
            sha256 = "049x6z6d3ssfx6rh8y11var1chj3x67nfrakigydnj3961hnr6ar";
          };
          nord-wallpaper = super.fetchurl {
            url = "https://raw.githubusercontent.com/dxnst/nord-backgrounds/9334ccc197cf0e4299778fd6ff4202fdbe2756f2/music/3840x2160/bjorkvespertine.png";
            sha256 = "bZQVGQHO+YZ5aVfBdHbEELz1Zu4dBnO33w21nKVoHZ4=";
          };
          pomo = super.callPackage ../../packages/pomo.nix { };
          wezterm-nightly = super.callPackage ../../packages/wezterm-nightly { };
          gnome-feeds-nightly = super.callPackage ../../packages/gnome-feeds-nightly { };
          writeBabashkaScript = super.callPackage ../../packages/write-babashka-script.nix { };
          cycle-pulse-sink = self.writeBabashkaScript {
            name = "cycle-pulse-sink";
            source = ../../misc/cycle-pulse-sink.clj;
            runtimeInputs = [ self.pulseaudio ];
          };
          cycle-sway-scale = self.writeBabashkaScript {
            name = "cycle-sway-scale";
            source = ../../misc/cycle-sway-scale.clj;
            runtimeInputs = [ self.sway ];
          };
          tmux-snapshot = super.writeShellApplication {
            name = "tmux-snapshot";
            runtimeInputs = [ self.coreutils-full self.procps self.hostname self.gnused self.tmux self.gnugrep self.gnutar self.gzip self.findutils ];
            text = ''
              if tmux has-session; then
                echo "tmux is running, saving snapshot..."
                ${self.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh quiet
              else
                echo "tmux is not running"
              fi
            '';
          };
          truecolor-test = super.writeShellApplication {
            name = "truecolor-test";
            runtimeInputs = [ self.coreutils self.gawk ];
            text = ''
              awk 'BEGIN{
                  s="/\\/\\/\\/\\/\\"; s=s s s s s s s s s s s s s s s s s s s s s s s;
                  for (colnum = 0; colnum<256; colnum++) {
                      r = 255-(colnum*255/255);
                      g = (colnum*510/255);
                      b = (colnum*255/255);
                      if (g>255) g = 510-g;
                      printf "\033[48;2;%d;%d;%dm", r,g,b;
                      printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
                      printf "%s\033[0m", substr(s,colnum+1,1);
                  }
                  printf "\n";
              }'
            '';
          };
          rebuild = super.writeShellApplication {
            name = "rebuild";
            runtimeInputs = with super; [ coreutils nixos-rebuild mpv ];
            text = ''
              LOG_DIR="$HOME/tmp/rebuild"
              STATUS_FILE="$LOG_DIR/status"
              LOG_FILE="$LOG_DIR/$(date +%Y-%m-%dT%H:%M:%S%Z)"
              LOG_LINK="$LOG_DIR/latest"
              CONFIG_DIR="$HOME/nixos-config"

              rebuild() {
                # Using --impure because reading from a <agenix-secret>.path requires it
                /run/wrappers/bin/doas nixos-rebuild --impure --option eval-cache false switch --flake "$CONFIG_DIR#" 2>&1 | tee "$LOG_FILE";
              }
              succeed() {
                echo "New generation created 🥳" | tee -a "$LOG_FILE";
                echo "" > "$STATUS_FILE";
                mpv ${self.success-alert} || true;
              }
              fail() {
                echo "Something went wrong 🤔" | tee -a "$LOG_FILE";
                echo "" > "$STATUS_FILE";
                mpv ${self.failure-alert} || true;
                exit 1;
              }

              mkdir -p "$LOG_DIR"
              echo "" > "$STATUS_FILE"
              touch "$LOG_FILE"
              ln -sf "$LOG_FILE" "$LOG_LINK";
              if rebuild; then succeed; else fail; fi
            '';
          };

          toggle-service = super.writeShellApplication {
            name = "toggle-service";
            runtimeInputs = [ self.systemd ];
            text = ''
              SERVICE="$1.service"
              if ! systemctl --user cat "$SERVICE" &> /dev/null; then
                echo "ERROR: Service does not exist"
                exit 1
              fi
              if systemctl --user is-active "$SERVICE"; then
                echo "Stopping service"
                systemctl --user stop "$SERVICE"
              else
                echo "Starting service"
                systemctl --user start "$SERVICE"
              fi
            '';
          };
          bitwig-studio = super.callPackage ../../packages/bitwig5.nix { };
          graillon-free = super.callPackage ../../packages/graillon.nix { };
          toggle-sway-window = self.writeBabashkaScript {
            name = "toggle-sway-window";
            source = ../../misc/toggle-sway-window.clj;
            runtimeInputs = [ super.sway ];
          };
          mixxx = super.symlinkJoin {
            name = "mixxx-wayland";
            paths = [ super.mixxx ];
            buildInputs = [ super.makeWrapper ];
            postBuild = "wrapProgram $out/bin/mixxx --add-flags '-platform xcb'";
          };
          check-newline = super.writeShellApplication {
            name = "check-newline";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              filename="$1"
              if [ ! -s "$filename" ]; then
                echo "$filename is empty"
              elif [ -z "$(tail -c 1 <"$filename")" ]; then
                echo "$filename ends with a newline or with a null byte"
              else
                echo "$filename does not end with a newline nor with a null byte"
              fi
            '';
          };
        })
      ];
    };

    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
      settings.auto-optimise-store = true;
      package = pkgs.nixFlakes; # Enable nixFlakes on system
      registry.nixpkgs.flake = inputs.nixpkgs;
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs          = true
        keep-derivations      = true
        warn-dirty            = false
      '';
    };

    systemd.extraConfig = ''
      [Manager]
      DefaultTimeoutStopSec=10
      DefaultTimeoutAbortSec=10
    '';

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      cpu.amd.updateMicrocode = true;
    };

  };
}
