{ pkgs, lib, ... }: {

  gtk = {
    enable = true;
    font = {
      name = "FiraMono Nerd Font";
      size = 10;
    };
    theme = {
      package = pkgs.nordic;
      name = "Nordic";
    };
    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy";
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-theme-name = "Nordic";
      gtk-icon-theme-name = "Nordzy";
      gtk-cursor-theme-name = "Nordzy-cursors";
    };
  };

  home = {
    sessionVariables = {
      # For gnome calculator, probably nautilus too
      GTK_THEME = "Nordic";
    };
    pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      # Sway seems unaffected by this size and defaults to 24
      size = 24;
      gtk.enable = true;
    };
    packages = [
      pkgs.calibre
      pkgs.gimp-with-plugins
      pkgs.qbittorrent
      pkgs.ungoogled-chromium
      pkgs.gnome.gnome-disk-utility
      pkgs.spotify
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
      pkgs.zoom-us
      pkgs.gnome-feeds
      pkgs.gnome.dconf-editor
      pkgs.jellyfin-media-player
      pkgs.cycle-pulse-sink
    ];
  };

  qt = {
    # Necessary for keepassxc, qpwgrapgh, etc to theme correctly
    enable = true;
    platformTheme = "gtk";
    style.name = "gtk2";
  };

  xdg.configFile = {
    # I'm using nemo (comes with cinnamon) instead of dolphin now
    # https://wiki.archlinux.org/title/Dolphin#Mismatched_folder_view_background_colors
    kdeglobals.text = ''
      [Colors:View]
      BackgroundNormal=#2e3440
    '';
    "wofi/config".text = "allow_images=true";
    "wofi/style.css".source = ../../misc/wofi.css;
    "pomo.cfg" = {
      onChange = ''
        ${pkgs.systemd}/bin/systemctl --user restart pomo-notify.service
      '';
      source = pkgs.writeShellScript "pomo-cfg" ''
        # This file gets sourced by pomo.sh at startup
        # I'm only caring about linux atm
        function custom_notify {
            # send_msg is defined in the pomo.sh source
            block_type=$1
            if [[ $block_type -eq 0 ]]; then
                echo "End of work period"
                send_msg 'End of a work period. Locking Screen!'
                ${pkgs.playerctl}/bin/playerctl --all-players stop
                ${pkgs.mpv}/bin/mpv ${pkgs.pomo-alert} || sleep 10
                if ${pkgs.procps}/bin/pgrep sway &> /dev/null; then
                  echo "Sway detected"
                  { ${pkgs.swaylock}/bin/swaylock; ${pkgs.pomo}/bin/pomo start; } &
                fi
            elif [[ $block_type -eq 1 ]]; then
                echo "End of break period"
                send_msg 'End of a break period. Time for work!'
                ${pkgs.mpv}/bin/mpv ${pkgs.pomo-alert}
            else
                echo "Unknown block type"
                exit 1
            fi
        }
        POMO_MSG_CALLBACK="custom_notify"
        POMO_WORK_TIME=28
        POMO_BREAK_TIME=8
      '';
    };
  };

  systemd.user.services.pomo-notify = {
    Unit = {
      Description = "pomo.sh notify daemon";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.pomo}/bin/pomo notify";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

}
