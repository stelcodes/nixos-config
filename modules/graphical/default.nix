{ pkgs, inputs, config, lib, ... }: {

  config = lib.mkIf config.profile.graphical {

    environment.systemPackages = lib.lists.optionals config.profile.virtualHost [
      pkgs.virt-manager
      pkgs.virt-viewer
      pkgs.spice
      pkgs.spice-gtk
      pkgs.spice-protocol
      pkgs.win-virtio
      pkgs.win-spice
      pkgs.gnome.adwaita-icon-theme # Do I need this?
    ];

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
      xpadneo.enable = config.activities.gaming;
    };

    programs = {

      # Need this for font-manager or any other gtk app to work I guess
      dconf.enable = true;

      sway.enable = true;

      steam.enable = config.activities.gaming;

      firefox = {
        enable = true;
        # https://mozilla.github.io/policy-templates/
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
              # It looks like firefox doesn't allow font settings to be overridden
              "font.name.monospace.x-western" = locked "FiraMono Nerd Font";
              "font.size.monospace.x-western" = locked 16;
              "media.ffmpeg.vaapi.enabled" = locked true;
            };
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableSetDesktopBackground = true;
          DisableTelemetry = true;
          DisplayBookmarksToolbar = "newtab";
          DontCheckDefaultBrowser = true;
          DNSOverHTTPS = {
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
              install_url = "https://github.com/mkaply/queryamoid/releases/download/v0.2/query_amo_addon_id-0.2-fx.xpi";
            };
            "uBlock0@raymondhill.net" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            };
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
            };
            "{73a6fe31-595d-460b-a920-fcc0f8843232}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/noscript/latest.xpi";
            };
            "myallychou@gmail.com" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/youtube-recommended-videos/latest.xpi";
            };
            "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/old-reddit-redirect/latest.xpi";
            };
            "@testpilot-containers" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/multi-account-containers/latest.xpi";
            };
          };
          HardwareAcceleration = true;
          Homepage = {
            URL = "chrome://browser/content/blanktab.html";
            Locked = false;
            StartPage = "none";
          };
          ManagedBookmarks = [
            { toplevel_name = "Default"; }
            { name = "Printing"; url = "localhost:631"; }
            { name = "Syncthing"; url = "localhost:8384"; }
            { name = "Jellyfin"; url = "macmini:8096"; }
            { name = "Firefox Policies"; url = "mozilla.github.io/policy-templates"; }
          ];
          ManualAppUpdateOnly = true;
          NewTabPage = false;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          OverrideFirstRunPage = "";
          PasswordManagerEnabled = false;
          Permissions = {
            Notifications = {
              BlockNewRequests = true;
              Locked = true;
            };
          };
          WebsiteFilter = {
            Block = [
              "*://news.ycombinator.com/*"
            ];
            Exceptions = [ ];
          };
        };
      };

      chromium = {
        enable = false;
        extensions = [
          "gighmmpiobklfepjocnamgkkbiglidom" # adblock
        ];
        # MANUAL SETTINGS:
        # chrome://settings/appearance
        #   Enable 'Use GTK'
        #   Enable 'Use system title bar and borders'
        # chrome://settings/syncSetup
        #   Disable 'Make searches and browsing better'
        # chrome://settings/searchEngines
        #   Enable DuckDuckGo default browser
        extraOpts = {
          AdvancedProtectionAllowed = false;
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          BackgroundModeEnabled = false;
          BatterySaverModeAvailability = 2;
          BlockThirdPartyCookies = true;
          BrowserNetworkTimeQueriesEnabled = false;
          BrowserSignin = 0;
          DefaultBrowserSettingEnabled = false;
          DefaultClipboardSetting = 2;
          DefaultCookiesSetting = 4;
          DefaultFileSystemReadGuardSetting = 2;
          DefaultFileSystemWriteGuardSetting = 2;
          DefaultGeolocationSetting = 2;
          DefaultLocalFontsSetting = 2;
          DefaultNotificationsSetting = 2;
          DefaultPopupsSetting = 2;
          # DefaultSearchProviderEnabled = true;
          # DefaultSearchProviderName = "DuckDuckGo";
          # DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
          DefaultSensorsSetting = 2;
          DefaultSerialGuardSetting = 2;
          DefaultThirdPartyStoragePartitioningSetting = 2;
          DefaultWebBluetoothGuardSetting = 2;
          DefaultWebHidGuardSetting = 2;
          DefaultWebUsbGuardSetting = 2;
          DefaultWindowManagementSetting = 2;
          DNSInterceptionChecksEnabled = false;
          DnsOverHttpsMode = "automatic";
          EnableMediaRouter = false;
          EnterpriseRealTimeUrlCheckMode = 0;
          HardwareAccelerationModeEnabled = true;
          HighEfficiencyModeEnabled = true;
          HttpsOnlyMode = "force_enabled";
          HomepageIsNewTabPage = true;
          MediaRecommendationsEnabled = false;
          MetricsReportingEnabled = false;
          NTPCardsVisible = false;
          NTPCustomBackgroundEnabled = true;
          PasswordLeakDetectionEnabled = false;
          PasswordManagerEnabled = false;
          PromotionalTabsEnabled = false;
          PaymentMethodQueryEnabled = false;
          SafeBrowsingProtectionLevel = 0;
          ScreenCaptureAllowed = false;
          SearchSuggestEnabled = false;
          ShoppingListEnabled = false;
          SpellcheckEnabled = false;
          SyncDisabled = true;
          # https://chromeenterprise.google/policies/#URLBlocklist
          UserAgentReduction = 2;
        };
      };

      thunar = {
        enable = true;
        plugins = [
          pkgs.xfce.thunar-archive-plugin
          pkgs.xfce.thunar-volman
        ];
      };

      file-roller.enable = true;
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
      printing = {
        enable = true;
        drivers = [
          pkgs.hplip
        ];
      };

      # Configure keymap in X11
      xserver = {
        enable = true;
        autorun = lib.mkDefault false;
        layout = pkgs.lib.mkDefault "us";
        xkbVariant = pkgs.lib.mkDefault "";
        xkbOptions = pkgs.lib.mkDefault "caps:escape_shifted_capslock,altwin:swap_alt_win";
        libinput.enable = true;
        # desktopManager.cinnamon.enable = true;
      };

      getty.autologinUser = config.admin.username;

      # Enable iOS devices to automatically connect
      # Use idevice* commands like ideviceinfo
      usbmuxd.enable = true;

      blueman.enable = true;

      gnome.gnome-keyring.enable = true;

      # For thunar https://nixos.wiki/wiki/Thunar
      gvfs.enable = true;
      tumbler.enable = true;

      spice-vdagentd.enable = config.profile.virtualHost;
    };

    fonts = {
      fontconfig.enable = true;
      enableDefaultPackages = true;
      packages = [
        # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
        (pkgs.nerdfonts.override { fonts = [ "FiraMono" ]; })
      ];
    };

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
      };
    };

    specialisation = {
      # gnome.configuration = {
      #   environment.gnome.excludePackages = with pkgs; [
      #     gnome-tour
      #     gnome-user-docs
      #     orca
      #     baobab
      #     epiphany
      #     gnome.gnome-backgrounds
      #     gnome.gnome-color-manager
      #     gnome.gnome-themes-extra
      #     gnome.gnome-shell-extensions
      #     gnome.yelp
      #     gnome.cheese
      #     gnome.gnome-contacts
      #     gnome.gnome-music
      #     gnome.gnome-system-monitor
      #     gnome-text-editor
      #     gnome.gnome-clocks
      #     gnome.gnome-weather
      #     gnome.gnome-maps
      #     gnome.simple-scan
      #     gnome.gnome-characters
      #     gnome-connections
      #     gnome.gnome-logs
      #     gnome.totem
      #     gnome.geary
      #     gnome-photos
      #     gnome.gnome-calendar
      #   ];
      #   services.xserver = {
      #     autorun = true;
      #     desktopManager.gnome.enable = true;
      #   };
      # };
      # plasma.configuration = {
      #   # X11 apps in Plasma wayland with fractional scaling are either blurry (global scaling) or scaled very small (app scaling)
      #   # So plasma X11 is the only option for fractional scaling and I like cinnamon better
      #   # environment.plasma5.excludePackages = [ ];
      #   home-manager.users.${config.admin.username} = {
      #     qt.enable = lib.mkForce false;
      #   };
      #   services = {
      #     gnome.gnome-keyring.enable = lib.mkForce false;
      #     xserver = {
      #       autorun = true;
      #       desktopManager.cinnamon.enable = lib.mkForce false;
      #       desktopManager.plasma5 = {
      #         enable = true;
      #         # useQtScaling = true;
      #       };
      #     };
      #   };
      # };
    };

  };
}
