{ pkgs, lib, config, inputs, ... }: {
  config = {
    boot.tmp.cleanOnBoot = true;

    # Enable networking
    networking.networkmanager.enable = true;
    networking.hosts."127.0.0.1" = [ "lh" ];
    networking.hosts."104.236.219.156" = [ "nube1" ];
    networking.hosts."167.99.122.78" = [ "morado1" ];
    networking.hosts."192.168.0.25" = [ "macmini" ];

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
      # https://terminal.sexy - JSON Scheme export
      # Nord terminal.app theme
      colors = [
        "2d3241"
        "b14a56"
        "92b477"
        "e6c274"
        "6d8eb5"
        "a5789e"
        "75b3c7"
        "dfe3ed"
        "3b4358"
        "b14a56"
        "92b477"
        "e6c274"
        "6d8eb5"
        "a5789e"
        "7cafad"
        "e7ebf1"
      ];
    };

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
      };
    };

    security.doas.enable = true;
    security.doas.extraRules = [{
      users = [ "stel" ];
      keepEnv = true;
      noPass = true;
      # persist = true;
    }];
    # security.sudo.enable = false;
    # security.acme.email = "stel@stel.codes";
    # security.acme.acceptTerms = true;

    users.mutableUsers = true;
    # Don't forget to set a password with ‘passwd’.
    users.users.stel = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "tty" "dialout" "audio" "video" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
      ];
      shell = pkgs.fish;
    };

    programs.fish.enable = lib.mkDefault true;

    environment.systemPackages =
      with pkgs; [
        vim
        # CORE UTILS
        bat
        htop
        procs
        trash-cli
        fd
        neofetch
        httpie
        wget
        ripgrep
        tealdeer
        unzip
        restic
        exa
        just
        fcp
        # PRINTING
        hplip
        # CODING
        git
        nixfmt
        nix-prefetch-github
        sqlite
        dua
        croc
        yt-dlp
        ranger
      ];

    # Nice to have, required for gnome-disks to work
    services.udisks2.enable = true;

    nixpkgs = {
      config = {
        allowInsecure = true;
        allowUnfree = true;
      };
      overlays = [
        (self: super: rec {
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
          obsidian = super.symlinkJoin {
            name = "obsidian-wayland";
            paths = [ super.obsidian ];
            buildInputs = [ super.makeWrapper ];
            postBuild = "wrapProgram $out/bin/obsidian --add-flags '--enable-features=WaylandWindowDecorations --ozone-platform-hint=auto'";
          };
          discord = super.symlinkJoin {
            name = "discord-wayland";
            paths = [ super.discord ];
            buildInputs = [ super.makeWrapper ];
            postBuild = "wrapProgram $out/bin/discord --add-flags '--enable-features=WaylandWindowDecorations --ozone-platform-hint=auto'";
          };
          ungoogled-chromium = super.symlinkJoin {
            name = "ungoogled-chromium-wayland";
            paths = [ super.ungoogled-chromium ];
            buildInputs = [ super.makeWrapper ];
            postBuild = "wrapProgram $out/bin/chromium --add-flags '--enable-features=WaylandWindowDecorations --ozone-platform-hint=auto'";
          };
          spotify = super.symlinkJoin {
            name = "spotify-wayland";
            paths = [ super.spotify ];
            buildInputs = [ super.makeWrapper ];
            postBuild = "wrapProgram $out/bin/spotify --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'";
          };
          protonvpn-cli = super.pkgs.protonvpn-cli_2;
          pomo = super.callPackage ../../packages/pomo.nix { };
          signal-desktop = super.symlinkJoin {
            name = "signal-desktop-wayland";
            paths = [ super.signal-desktop ];
            buildInputs = [ super.makeWrapper ];
            postBuild = "wrapProgram $out/bin/signal-desktop --add-flags '--enable-features=UseOzonePlatform --ozone-platform=wayland'";
          };
          wezterm-nightly = super.callPackage ../../packages/wezterm-nightly { };
          gnome-feeds-nightly = super.callPackage ../../packages/gnome-feeds-nightly { };
          writeBabashkaScript = super.callPackage ../../packages/write-babashka-script.nix { };
          cycle-pulse-sink = writeBabashkaScript {
            name = "cycle-pulse-sink";
            source = ../../misc/cycle-pulse-sink.clj;
            runtimeInputs = [ super.pulseaudio ];
          };
          tmux-snapshot = pkgs.writeShellApplication {
            name = "tmux-snapshot";
            runtimeInputs = [ pkgs.coreutils-full pkgs.procps pkgs.hostname pkgs.gnused pkgs.tmux ];
            text = ''
              if tmux has-session; then
                echo "tmux is running, saving snapshot..."
                ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh quiet
              else
                echo "tmux is not running"
              fi
            '';
          };
          truecolor-test = pkgs.writeShellApplication {
            name = "truecolor-test";
            text = ''
              ${pkgs.gawk}/bin/awk 'BEGIN{
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
          rebuild = pkgs.writeShellApplication {
            name = "rebuild";
            runtimeInputs = with pkgs; [ coreutils nixos-rebuild mpv ];
            text = ''
              STATUS_FILE=/tmp/nixos-rebuild.status
              LOG_FILE=/tmp/nixos-rebuild.log

              rebuild() { /run/wrappers/bin/doas nixos-rebuild switch --flake "$HOME/nixos-config#" 2>&1 | tee $LOG_FILE; }
              succeed() { echo "new generation created 🥳" | tee -a $LOG_FILE; echo "" > $STATUS_FILE; mpv ${pkgs.success-alert} || true; }
              fail() { echo "something went wrong 🤔" | tee -a $LOG_FILE; echo "" > $STATUS_FILE; mpv ${pkgs.failure-alert} || true; exit 1; }

              echo "" > $STATUS_FILE
              if rebuild; then succeed; else fail; fi
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
      '';
    };

    systemd.extraConfig = ''
      [Manager]
      DefaultTimeoutStopSec=10
      DefaultTimeoutAbortSec=10
    '';
  };
}
