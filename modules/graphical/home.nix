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
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
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
                ${pkgs.vlc}/bin/cvlc --play-and-exit ${pkgs.pomo-alert} || sleep 10
                if ${pkgs.procps}/bin/pgrep sway &> /dev/null; then
                  echo "Sway detected"
                  { ${pkgs.swaylock}/bin/swaylock; ${pkgs.pomo}/bin/pomo start; } &
                elif ${pkgs.procps}/bin/pgrep cinnamon &> /dev/null; then
                  echo "Cinnamon detected"
                  ${pkgs.cinnamon.cinnamon-screensaver}/bin/cinnamon-screensaver-command -a
                  {
                    while ${pkgs.cinnamon.cinnamon-screensaver}/bin/cinnamon-screensaver-command --query | ${pkgs.gnugrep}/bin/grep -q 'is active'; do
                      sleep 5;
                    done
                    ${pkgs.pomo}/bin/pomo start;
                  } &
                fi
            elif [[ $block_type -eq 1 ]]; then
                echo "End of break period"
                send_msg 'End of a break period. Time for work!'
                ${pkgs.vlc}/bin/cvlc --play-and-exit ${pkgs.pomo-alert}
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


  dconf.settings =
    with lib.hm.gvariant;
    let bind = x: mkArray type.string [ x ];
    in
    {
      "org/cinnamon" = {
        alttab-switcher-delay = mkInt32 0;
        hotcorner-layout = mkArray type.string [
          "expo:true:0"
          ":false:0"
          ":false:0"
          ":false:0"
        ];
      };
      "org/cinnamon/theme" = {
        name = "Nordic";
      };
      "org/cinnamon/sounds" = {
        notification-enabled = false;
      };
      "org/cinnamon/desktop/keybindings/wm" = {
        close = bind "<Shift><Super>q";
        move-to-workspace-left = bind "<Shift><Super>h";
        move-to-workspace-right = bind "<Shift><Super>l";
        switch-to-workspace-left = bind "<Super>h";
        switch-to-workspace-right = bind "<Super>l";
        switch-windows = bind "<Super>Tab";
        toggle-fullscreen = bind "<Super>Space";
        show-desktop = bind "<Super>x";
      };
      "org/cinnamon/desktop/keybindings/media-keys" = {
        logout = bind "<Shift><Super>e";
        terminal = bind "<Super>Return";
        www = bind "<Super>BackSpace";
        screensaver = bind "<Super>Delete";
        home = bind "<Super>f";
      };
      "org/cinnamon/desktop/wm/preferences" = {
        # titlebar-font = "FiraMono Nerd Font Medium 10";
      };
      "org/cinnamon/desktop/interface" = {
        cursor-size = "24";
        cursor-theme = "Nordzy-cursors";
        # ubuntu medium 10 is default
        # font-name = "FiraMono Nerd Font 11";
        gtk-theme = "Nordic";
        icon-theme = "Nordzy";
      };
      "org/cinnamon/desktop/applications/terminal" = {
        exec = "${pkgs.wezterm}/bin/wezterm";
      };

      # Menu settings are not stored in dconf database >.>"
      # They're kept in a json file at .config/cinnamon/spices/menu@cinnamon.org/
      # They can be changed by right clicking the menu icon -> configure
      # I'm just manually set <Super>d menu shortcut for now

      # Calendar
      # Same deal
      # Format: %b %e %l:%M %p

      # Maybe set these in the future?
      # org.gnome.desktop.interface
      # org.gnome.desktop.wm.preferences
      # org.cinnamon.desktop.background picture-uri "file://${pkgs.nord-wallpaper}"
    };

}
