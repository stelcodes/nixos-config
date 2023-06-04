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

    # Hibernate after 45 minutes of sleep
    systemd = {
      sleep.extraConfig = "HibernateDelaySec=45m";
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
              locked = (x: { Status = "locked"; Value = x; });
            in
            {
              "browser.chrome.toolbar_tips" = locked false;
              "browser.uidensity" = locked 1;
              "browser.fullscreen.autohide" = locked false;
              "browser.tabs.insertAfterCurrent" = locked true;
              "browser.urlbar.suggest.quicksuggest.nonsponsored" = locked false;
              "browser.urlbar.suggest.quicksuggest.sponsored" = locked false;
              "browser.urlbar.suggest.topsites" = locked false;
              "browser.urlbar.suggest.calculator" = locked true;
              "browser.urlbar.suggest.engines" = locked false;
              "browser.urlbar.suggest.searches" = locked false;
              "dom.security.https_only_mode" = locked true;
              "font.name.monospace.x-western" = user "FiraMono Nerd Font";
              "font.name.sans-serif.x-western" = user "FiraMono Nerd Font";
              "font.name.serif.x-western" = user "FiraMono Nerd Font";
              "media.ffmpeg.vaapi.enabled" = locked true;
            };
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableSetDesktopBackground = true;
          DisableTelemetry = true;
          DisplayBookmarksToolbar = "newtab";
          DontCheckDefaultBrowser = true;
          DNSOverHTTPS = {
            # Solves my protonvpn reconnect dns issue
            Enabled = true;
            Locked = true;
          };
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
            Exceptions = [ ];
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
          HardwareAcceleration = true;
          Homepage = {
            URL = "chrome://browser/content/blanktab.html";
            Locked = false;
            StartPage = "none";
          };
          NewTabPage = false;
          OfferToSaveLogins = false;
          OverrideFirstRunPage = "";
          PasswordManagerEnabled = false;
          WebsiteFilter = {
            Block = [
              "*://news.ycombinator.com/*"
              "*://*.reddit.com/"
              "*://*.reddit.com/?*"
              "*://*.reddit.com/r/popular/*"
            ];
            Exceptions = [ ];
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
        layout = pkgs.lib.mkDefault "us";
        xkbVariant = pkgs.lib.mkDefault "";
        xkbOptions = pkgs.lib.mkDefault "caps:swapescape";
        libinput.enable = true;
        displayManager.startx.enable = true;
        displayManager.lightdm.enable = false;
        desktopManager.cinnamon.enable = true;
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
        (pkgs.nerdfonts.override { fonts = [ "FiraMono" ]; })
      ];
    };

    environment.systemPackages = [
      pkgs.calibre
      pkgs.gimp-with-plugins
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
      pkgs.signal-desktop
      pkgs.slack
    ];

  };
}
