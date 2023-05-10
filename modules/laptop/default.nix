{ pkgs, ... }: {
  imports = [ ];

  config = {

    sound.enable = true;

    # Needed for pipewire
    security.rtkit.enable = true;

    hardware = {
      bluetooth.enable = true;
      opengl = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiVdpau
          libvdpau-va-gl
        ];
      };
      # Use pipewire instead of pulseaudio
      pulseaudio.enable = false;
    };

    # Hibernate after 30 minutes of sleep
    systemd = {
      sleep.extraConfig = "HibernateDelaySec=30m";
    };

    programs = {

      # Need this for font-manager or any other gtk app to work I guess
      dconf.enable = true;

      sway.enable = true;

      firefox = {
        enable = true;
        # https://github.com/mozilla/policy-templates/blob/master/README.md
        # Apparently Mozilla doesn't let you set the default search engine using policies anymore >:c
        policies = {
          Preferences =
            let
              user = (x: { Status = "user"; Value = x; });
            in
            {
              "browser.chrome.toolbar_tips" = user false;
              "browser.uidensity" = user 1;
              "browser.fullscreen.autohide" = user false;
              "browser.tabs.insertAfterCurrent" = user true;
              "browser.newtabpage.enabled" = user false;
              "browser.startup.homepage" = user "chrome://browser/content/blanktab.html";
              "browser.shell.checkDefaultBrowser" = user false;
              "font.name.monospace.x-western" = user "NotoSansMono Nerd Font";
              "font.name.sans-serif.x-western" = user "NotoSans Nerd Font";
              "font.name.serif.x-western" = user "NotoSerif Nerd Font";
              "media.ffmpeg.vaapi.enabled" = user true;
              "extensions.pocket.enabled" = user false;
            };
          DNSOverHTTPS = {
            # Solves my protonvpn reconnect dns issue
            Enabled = true;
            Locked = true;
          };
          ExtensionSettings = {
            # https://github.com/mkaply/queryamoid/releases/tag/v0.1
            "queryamoid@kaply.com" = {
              installation_mode = "normal_installed";
              install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.1/query_amo_addon_id-0.1-fx.xpi";
            };
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

      # getty.autologinUser = "stel";

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
            "* * * * * root ${hibernateCriticalBattery}"
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
      pkgs.gnome.gnome-disk-utility
      pkgs.spotify
      pkgs.hplip
      pkgs.libimobiledevice # For iphone hotspot tethering
      pkgs.obsidian
      pkgs.discord
      pkgs.pavucontrol
      pkgs.tor-browser-bundle-bin # tor-browser not working 4/16/23
      pkgs.vlc
      pkgs.mpv
      pkgs.appimage-run
      pkgs.protonvpn-cli
    ];

  };
}
