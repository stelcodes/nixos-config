{ pkgs, inputs, ... }: {
  imports = [
    inputs.musnix.nixosModules.musnix
  ];

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

    programs = {

      # Need this for font-manager or any other gtk app to work I guess
      dconf.enable = true;

      sway.enable = true;

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
            "addon@darkreader.org" = {
              # brightness 35, contrast -5
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            };
            "{73a6fe31-595d-460b-a920-fcc0f8843232}" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/noscript/latest.xpi";
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
            { name = "Printing"; url = "localhost:631"; }
            { name = "Firefox Policies"; url = "mozilla.github.io/policy-templates"; }
            { name = "Jellyfin"; url = "macmini:8096"; }
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
              "*://*.youtube.com/*"
              "*://*.reddit.com/"
              "*://*.reddit.com/?*"
              "*://*.reddit.com/r/popular"
              "*://*.reddit.com/r/popular?*"
              "*://*.reddit.com/r/popular/*"
              "*://*.tmz.com/*"
            ];
            Exceptions = [ ];
          };
        };
      };

      chromium = {
        enable = true;
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
          URLBlocklist = [
            "news.ycombinator.com"
            "reddit.com"
            "youtube.com"
            "tmz.com"
          ];
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
        autorun = false;
        layout = pkgs.lib.mkDefault "us";
        xkbVariant = pkgs.lib.mkDefault "";
        xkbOptions = pkgs.lib.mkDefault "caps:escape,altwin:swap_alt_win";
        libinput.enable = true;
        # I can't for the love of god get a decent multi-desktop setup with sway
        # It's just too damn hard and I'm giving up forever
        # displayManager.startx.enable = true;
        # desktopManager.cinnamon.enable = true;
      };

      # getty.autologinUser = "stel";

      # Enable iOS devices to automatically connect
      # Use idevice* commands like ideviceinfo
      usbmuxd.enable = true;

      blueman.enable = true;

      gnome.gnome-keyring.enable = true;

      # For thunar https://nixos.wiki/wiki/Thunar
      gvfs.enable = true;
      tumbler.enable = true;

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

  };
}
