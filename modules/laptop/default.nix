{ pkgs, ... }: {
  imports = [ ];

  config = {

    sound.enable = true;

    # Needed for pipewire
    security.rtkit.enable = true;

    hardware = {
      bluetooth.enable = true;
      opengl.enable = true;
      # Use pipewire instead of pulseaudio
      pulseaudio.enable = false;
    };

    # Hibernate after 30 minutes of sleep
    systemd.sleep.extraConfig = "HibernateDelaySec=30m";

    programs = {

      # Need this for font-manager or any other gtk app to work I guess
      dconf.enable = true;

      sway.enable = true;

      # https://github.com/mkaply/queryamoid/releases/tag/v0.1
      # https://github.com/mozilla/policy-templates/blob/master/README.md#extensionsettings
      # Apparently Mozilla doesn't let you set the default search engine using policies anymore >:c
      firefox = {
        enable = true;
        preferences = {
          "browser.chrome.toolbar_tips" = false;
          "browser.uidensity" = 1;
          "browser.fullscreen.autohide" = false;
          "browser.tabs.insertAfterCurrent" = true;
          "browser.newtabpage.enabled" = false;
          "browser.startup.homepage" = "chrome://browser/content/blanktab.html";
          "browser.shell.checkDefaultBrowser" = false;
        };
        policies = {
          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            };
            "vimium-c@gdh1995.cn" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
            };
          };
        };
      };

    };

    services = {

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      # Enable CUPS to print documents.
      printing.enable = true;

      # Configure keymap in X11
      xserver = {
        enable = true;
        autorun = false;
        layout = "us";
        xkbVariant = "";
        xkbOptions = "caps:swapescape";
        libinput.enable = true;
      };

      getty.autologinUser = "stel";

      # Enable iOS devices to automatically connect
      # Use idevice* commands like ideviceinfo
      usbmuxd.enable = true;

      blueman.enable = true;

      gnome.gnome-keyring.enable = true;

      # don’t shutdown when power button is short-pressed
      logind.extraConfig = "HandlePowerKey=hibernate";
      logind.lidSwitch = "suspend-then-hibernate";

      cron = {
        enable = true;
        # https://crontab.guru
        systemCronJobs =
          let
            hibernateCriticalBattery = pkgs.writeShellScript "hibernate-critical-battery" ''
              ${pkgs.acpi}/bin/acpi -b | ${pkgs.gawk}/bin/awk -F'[,:%]' '{print $2, $3}' | {
                read -r status capacity
                if [ "$status" = Discharging -a "$capacity" -lt 8 ]; then
                  ${pkgs.systemd}/bin/systemctl hibernate
                fi
              }
            '';
          in
          [
            "* * * * * ${hibernateCriticalBattery}"
          ];
      };
    };


    powerManagement = {
      enable = true;
      powertop.enable = true;
      # powertop --auto-run will run at boot
      # Run powertop --calibrate at first
      # Maybe switch to services.tlp if I need configuration
    };

    fonts = {
      fontconfig.enable = true;
      enableDefaultFonts = true;
      fonts = [
        # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
        (pkgs.nerdfonts.override { fonts = [ "Noto" "JetBrainsMono" ]; })
      ];
    };

    environment.systemPackages = [
      pkgs.calibre
      pkgs.gimp
      pkgs.qbittorrent
      pkgs.ungoogled-chromium
      # partitioning
      pkgs.gnome.gnome-disk-utility
      # music
      pkgs.spotify
      #printing
      pkgs.hplip
      # pkgs.mpv-unwrapped
      # For iphone hotspot tethering
      pkgs.libimobiledevice
      pkgs.obsidian-wayland
      pkgs.pavucontrol
      # pkgs.libsForQt5.qt5.qtwayland
      pkgs.tor-browser-bundle-bin
      pkgs.vlc
    ];

  };
}
