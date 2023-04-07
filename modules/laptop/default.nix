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
    # displayManager.startx.enable = true;


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
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # don’t shutdown when power button is short-pressed
    services.logind.extraConfig = "HandlePowerKey=hibernate";
    services.logind.lidSwitch = "hybrid-sleep";
    services.dnsmasq.enable = true;
    services.dnsmasq.extraConfig = "address=/lh/127.0.0.1";

    fonts.fontconfig.enable = true;
    # https://git.io/Js0vT
    fonts.fontconfig.defaultFonts.emoji =
      [ "Noto Color Emoji" "Font Awesome 5 Free" "Font Awesome 5 Brands" ];
    # For Alacritty
    fonts.fontconfig.defaultFonts.monospace = [
      "Noto Sans Mono"
      "Noto Color Emoji"
      "Font Awesome 5 Free"
      "Font Awesome 5 Brands"
    ];
    fonts.fontconfig.defaultFonts.serif = [ "Noto Serif" ];
    fonts.fontconfig.defaultFonts.sansSerif = [ "Noto Sans" ];
    # fonts.enableDefaultFonts = true;
    fonts.fonts = [
      pkgs.font-awesome
      pkgs.noto-fonts-emoji
      pkgs.noto-fonts
      pkgs.powerline-fonts
      pkgs.jetbrains-mono
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/data/fonts/nerdfonts/shas.nix
      (pkgs.nerdfonts.override { fonts = [ "Noto" "JetBrainsMono" "OpenDyslexic" ]; })
    ];

    environment.systemPackages = with pkgs; [
      firefox
      urlview # move to tmux module
    ];
    programs.zsh.shellAliases = {
      "restic-backup-napi" =
        "restic -r /run/media/stel/Napi/restic-backups/ backup --files-from=/config/misc/restic/include.txt --exclude-file=/config/misc/restic/exclude.txt";
      "restic-mount-napi" =
        "restic -r /run/media/stel/Napi/restic-backups/ mount /home/stel/backups/Napi-restic";
      "restic-backup-mapache" =
        "restic -r /run/media/stel/Mapache/restic-backups/ backup --files-from=/config/misc/restic/include.txt --exclude-file=/config/misc/restic/exclude.txt";
      "restic-mount-mapache" =
        "restic -r /run/media/stel/Mapache/restic-backups/ mount /home/stel/backups/Mapache-restic";
      "pdf" = "evince-previewer";
      "play-latest-obs-recording" =
        "mpv $(ls /home/stel/videos/obs | sort --reverse | head -1)";
      "screenshot" =
        "slurp | grim -g - ~/pictures/screenshots/$(date +%F_%T)_screenshot.png";
      "vpn" = "doas protonvpn connect -f";
      "tether" = "doas dhcpcd";
      "backup-config" =
        "tar --create --gzip --file ~/backups/config/$(date +%F_%T)_config.tar.gz --directory=/config .";
      "protonmail" = "firefox --new-window mail.protonmail.com/login";
      "yt" = "youtube-dl -f \"best[height=720]\"";
      "gui" = "exec sway";
      "clj-repl" = "rlwrap clojure -M:repl";
      "wifi" = "nmtui";
    };
  };
}
