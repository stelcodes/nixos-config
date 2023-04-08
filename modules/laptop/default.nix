{ pkgs, ... }: {
  imports = [ ];

  config = {

    hardware.bluetooth.enable = true;
    hardware.opengl.enable = true;

    # Need this for font-manager or any other gtk app to work I guess
    programs.dconf.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Configure keymap in X11
    services.xserver = {
      enable = true;
      autorun = false;
      layout = "us";
      xkbVariant = "";
      xkbOptions = "caps:swapescape";
      libinput.enable = true;
    };

    # Enable iOS devices to automatically connect
    # Use idevice* commands like ideviceinfo
    services.usbmuxd.enable = true;

    services.blueman.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # don’t shutdown when power button is short-pressed
    services.logind.extraConfig = "HandlePowerKey=hibernate";
    services.logind.lidSwitch = "suspend-then-hibernate";
    systemd.sleep.extraConfig = "HibernateDelaySec=30m";

    fonts.fontconfig.enable = true;
    fonts.enableDefaultFonts = true;
    fonts.fonts = [
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
      (pkgs.nerdfonts.override { fonts = [ "Noto" "JetBrainsMono" ]; })
    ];

    # https://github.com/mkaply/queryamoid/releases/tag/v0.1
    # https://github.com/mozilla/policy-templates/blob/master/README.md#extensionsettings
    programs.firefox = {
      enable = true;
      policies = {
        # Extensions = ["https://addons.mozilla.org/firefox/downloads/latest/nord-firefox/latest.xpi"];
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
          "vimium-c@gdh1995.cn" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-c/latest.xpi";
          };
          "{26e789e7-acf2-4346-9381-ad473c245e43}" = {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/nord-firefox/latest.xpi";
          };
        };
      };
    };

  };
}
