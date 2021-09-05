{ pkgs, ... }: {
  imports = [ ../common ../alacritty ../sway ];

  config = {

    # Set your time zone.
    time.timeZone = "America/Los_Angeles";

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
    };
  };
}
