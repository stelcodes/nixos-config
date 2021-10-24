{ pkgs, ... }: {
  imports = [ ../common ../alacritty ../sway ];

  config = {

    # Set your time zone.
    time.timeZone = "America/Los_Angeles";

    # Enable ALSA sound.
    sound.enable = true;

    hardware.bluetooth.enable = true;
    hardware.opengl.enable = true;

    # Need this for font-manager or any other gtk app to work I guess
    programs.dconf.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable iOS devices to automatically connect
    # Use idevice* commands like ideviceinfo
    services.usbmuxd.enable = true;

    services.blueman.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # For upower to work? maybe?
    services.dbus.enable = true;

    services.upower.enable = true;
    services.upower.criticalPowerAction = "Hibernate";
    services.upower.percentageCritical = 10;

    services.pipewire.enable = true;
    services.pipewire.pulse.enable = true;
    services.pipewire.jack.enable = true;
    services.pipewire.alsa.enable = true;

    # don’t shutdown when power button is short-pressed
    services.logind.extraConfig = "HandlePowerKey=ignore";
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
    fonts.fonts = [
      pkgs.font-awesome
      pkgs.noto-fonts-emoji
      pkgs.noto-fonts
      pkgs.powerline-fonts
      # (pkgs.nerdfonts.override { fonts = [ "Noto" ]; })
    ];

    environment.systemPackages = with pkgs; [ xdg-utils ];
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
