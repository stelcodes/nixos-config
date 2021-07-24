{ pkgs, ... }: {
  imports = [ ../common ../alacritty ../sway ];

  config = {

    # Set your time zone.
    time.timeZone = "America/Denver";

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
        "slurp | grim -g - ~/pictures/screenshots/grim:$(date -Iseconds).png";
      "vpn" = "doas protonvpn connect -f";
      "tether" = "doas dhcpcd";
    };
  };
}
