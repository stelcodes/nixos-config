{ pkgs, lib, config, systemConfig, ... }:
let
  cfg = config.wayland.windowManager.sway;
  theme = systemConfig.theme.set;
  viewRebuildLogCmd = "foot --app-id=nixos_rebuild_log tail -n +1 -F -s 0.2 $HOME/tmp/rebuild/latest";
  mod = "Mod4";
  # Sway does not support input or output identifier pattern matching so in order to apply settings for every
  # Apple keyboard, I have to create a new rule for each Apple keyboard I use.
  appleKeyboardIdentifiers = [
    "1452:657:Apple_Inc._Apple_Internal_Keyboard_/_Trackpad"
  ];
  appleKeyboardConfig = lib.strings.concatMapStrings
    (id: ''
      input "${id}" {
        xkb_layout us
        xkb_options caps:escape_shifted_capslock
        xkb_variant mac
      }
    '')
    appleKeyboardIdentifiers;
  cycle-sway-output = pkgs.writeBabashkaScript {
    name = "cycle-sway-output";
    text = builtins.readFile ../../misc/cycle-sway-output.clj;
  };
  cycle-sway-scale = pkgs.writeBabashkaScript {
    name = "cycle-sway-scale";
    text = builtins.readFile ../../misc/cycle-sway-scale.clj;
  };
  toggle-sway-window = pkgs.writeBabashkaScript {
    name = "toggle-sway-window";
    text = builtins.readFile ../../misc/toggle-sway-window.clj;
  };
in
{

  options = {
    wayland.windowManager.sway = {
      lockBeforeSleep = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      idleSleep = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        lock = lib.mkOption {
          type = lib.types.bool;
          default = true;
        };
        timeout = lib.mkOption {
          type = lib.types.int;
          default = 1800;
        };
        sleepType = lib.mkOption {
          type = lib.types.enum [ "suspend" "hibernate" "hybrid-sleep" "suspend-then-hibernate" "poweroff" ];
          default = "suspend-then-hibernate";
        };
      };
      wallpaper = lib.mkOption {
        type = lib.types.nullOr lib.types.package;
        default = null;
      };
    };
  };

  config = lib.mkIf systemConfig.profile.graphical {

    home.packages = [
      pkgs.swaylock
      pkgs.swayidle
      pkgs.brightnessctl
      pkgs.playerctl
      pkgs.libinput
      pkgs.wev
      pkgs.font-manager
      pkgs.wl-clipboard
      pkgs.wofi
      pkgs.gnome3.adwaita-icon-theme # for the two icons in the default wofi setup
      pkgs.wlsunset
      pkgs.grim
      pkgs.slurp
      pkgs.pamixer
      pkgs.wofi-emoji
      pkgs.wtype
      pkgs.libnotify
      pkgs.pomo
      pkgs.wdisplays
      pkgs.foot
      pkgs.swappy
      pkgs.wl-screenrec # https://github.com/russelltg/wl-screenrec
      pkgs.wlogout
    ];

    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        # Fix for some Java AWT applications (e.g. Android Studio),
        # use this if they aren't displayed properly:
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        # Automatically add electron/chromium wayland flags
        export NIXOS_OZONE_WL=1
        # Fix for GTK scale issues when also using Cinnamon
        # export GDK_SCALE=1
        export GDK_DPI_SCALE=-1
        # Forgot what graphical program is being run from systemd user service
        # Could use systemd.user.extraConfig = '''DefaultEnvironment="GDK_DPI_SCALE=-1"'''
        systemctl --user import-environment GDK_DPI_SCALE
        export TERMINAL=foot
        export BROWSER=firefox;
      '';
      config = {
        fonts = {
          names = [ "FiraMono Nerd Font" ];
          style = "Regular";
          size = 8.0;
        };
        bars = [ ];
        colors = {
          focused = {
            background = theme.bg;
            border = theme.bg3;
            childBorder = theme.bg3;
            indicator = theme.green;
            text = theme.fg;
          };
          unfocused = {
            background = theme.black;
            border = theme.bg;
            childBorder = theme.bg;
            indicator = theme.bg3;
            text = theme.fg;
          };
          focusedInactive = {
            background = theme.black;
            border = theme.bg;
            childBorder = theme.bg;
            indicator = theme.bg3;
            text = theme.fg;
          };
        };
        window = {
          hideEdgeBorders = "smart";
          border = 1;
        };
        workspaceLayout = "tabbed";
        keybindings = {
          # Default keymaps
          "${mod}+h" = "focus left";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+l" = "focus right";
          "${mod}+shift+h" = "move left";
          "${mod}+shift+l" = "move right";
          "${mod}+shift+k" = "move up";
          "${mod}+shift+j" = "move down";
          "${mod}+shift+q" = "kill";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";
          "${mod}+shift+space" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+shift+1" = "move container to workspace number 1";
          "${mod}+shift+2" = "move container to workspace number 2";
          "${mod}+shift+3" = "move container to workspace number 3";
          "${mod}+shift+4" = "move container to workspace number 4";
          "${mod}+shift+5" = "move container to workspace number 5";
          "${mod}+shift+6" = "move container to workspace number 6";
          "${mod}+shift+7" = "move container to workspace number 7";
          "${mod}+shift+8" = "move container to workspace number 8";
          "${mod}+shift+9" = "move container to workspace number 9";
          "${mod}+shift+minus" = "move scratchpad";
          "${mod}+minus" = "scratchpad show";
          "${mod}+r" = "mode resize";

          # Custom sway-specific keymaps
          "${mod}+left" = "focus output left";
          "${mod}+down" = "focus output down";
          "${mod}+up" = "focus output up";
          "${mod}+right" = "focus output right";
          "${mod}+shift+left" = "move window to output left";
          "${mod}+shift+down" = "move window to output down";
          "${mod}+shift+up" = "move window to output up";
          "${mod}+shift+right" = "move window to output right";
          "${mod}+tab" = "workspace back_and_forth";
          "${mod}+less" = "focus parent";
          "${mod}+greater" = "focus child";
          "${mod}+semicolon" = "layout toggle split tabbed stacking";
          "${mod}+apostrophe" = "split toggle";
          "${mod}+shift+tab" = "exec ${lib.getExe cycle-sway-output}";
          "${mod}+shift+r" = "reload; exec systemctl --user restart waybar";
          "${mod}+shift+e" = "exec swaynag -t warning -m 'Do you really want to exit sway?' -b 'Yes, exit sway' 'swaymsg exit'";

          # Custom external program keymaps
          "${mod}+return" = "exec foot sh -c 'tmux attach || tmux new-session -s config -c \"$HOME/nixos-config\"; fish'";
          "${mod}+m" = "exec wofi --show run --width 800 --height 400 --term foot";
          "${mod}+shift+m" = "exec wofi --show drun --width 800 --height 400 --term foot";
          "${mod}+backspace" = "exec firefox";
          "${mod}+shift+backspace" = "exec firefox --private-window";
          "${mod}+grave" = "exec wofi-emoji";
          "${mod}+c" = "exec ${lib.getExe toggle-sway-window} --id nixos_rebuild_log -- ${viewRebuildLogCmd}";
          "${mod}+shift+c" = "exec rebuild";
          "${mod}+n" = "exec ${lib.getExe toggle-sway-window} --id nnn -- foot --app-id=nnn fish -c n ~";
          "${mod}+shift+n" = "exec makoctl dismiss --all";
          "${mod}+p" = "exec ${lib.getExe toggle-sway-window} --id pavucontrol -- pavucontrol";
          "${mod}+shift+p" = "exec ${lib.getExe pkgs.cycle-pulse-sink}";
          "${mod}+a" = "exec ${lib.getExe toggle-sway-window} --id audacious -- audacious";
          "${mod}+shift+a" = "exec ${lib.getExe pkgs.toggle-service} record-playback";
          "${mod}+d" = "exec ${lib.getExe toggle-sway-window} --id gnome-disks -- gnome-disks";
          "${mod}+v" = "exec ${lib.getExe toggle-sway-window} --id org.keepassxc.KeePassXC -- keepassxc";
          "${mod}+b" = "exec ${lib.getExe toggle-sway-window} --id .blueman-manager-wrapped -- blueman-manager";
          "${mod}+t" = "exec ${lib.getExe toggle-sway-window} --id btop -- foot --app-id=btop btop";
          "${mod}+backslash" = "exec ${lib.getExe cycle-sway-scale}";
          "${mod}+bar" = "exec ${lib.getExe pkgs.toggle-service} wlsunset";
          "${mod}+delete" = "exec swaylock";

          # Function key keymaps
          XF86MonBrightnessDown = "exec brightnessctl set 5%-";
          XF86MonBrightnessUp = "exec brightnessctl set +5%";
          XF86AudioPrev = "exec playerctl previous";
          XF86AudioPlay = "exec playerctl play-pause";
          XF86AudioNext = "exec playerctl next";
          XF86AudioMute = "exec pamixer --toggle-mute";
          XF86AudioLowerVolume = "exec pamixer --decrease 5";
          XF86AudioRaiseVolume = "exec pamixer --increase 5";
          "${mod}+Print" = "exec " + lib.getExe (pkgs.writeShellApplication {
            name = "sway-screenshot-selection";
            runtimeInputs = [ pkgs.coreutils-full pkgs.slurp pkgs.grim pkgs.swappy ];
            text = ''
              mkdir -p "$XDG_PICTURES_DIR/screenshots"
              grim -g "$(slurp)" - | swappy -f -
            '';
          });
          Print = "exec " + lib.getExe (pkgs.writeShellApplication {
            name = "sway-screenshot";
            runtimeInputs = [ pkgs.coreutils-full pkgs.sway pkgs.jq pkgs.grim pkgs.swappy ];
            text = ''
              mkdir -p "$XDG_PICTURES_DIR/screenshots"
              current_output=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
              grim -o "$current_output" - | swappy -f -
            '';
          });
        };
        modes = pkgs.lib.mkOptionDefault {
          resize = {
            "r" = "resize set width 80 ppt height 90 ppt, move position center";
          };
        };
        # There's a big problem with how home-manager handles the input and output values
        # The ordering *does* matter so the value should be a list, not a set.
        input = {
          "type:keyboard" = {
            # man xkeyboard-config
            xkb_options = "caps:escape_shifted_capslock,altwin:swap_alt_win";
            xkb_layout = "us";
          };
          "type:touchpad" = {
            natural_scroll = "enabled";
            dwt = "enabled";
            tap = "enabled";
            tap_button_map = "lrm";
          };
        };
        output = {
          "*" = {
            background = if (cfg.wallpaper != null) then "${cfg.wallpaper} fill ${theme.bg}" else "${theme.bg} solid_color";
          };
          # Framework screen
          "BOE 0x095F Unknown" = {
            scale = "1.6";
            position = "0 0";
          };
          # Epson projector
          "Seiko Epson Corporation EPSON PJ 0x00000101" = {
            position = "0 0";
          };
        };
        startup = [
          # Import sway-related environment variables into systemd user services
          { command = "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK I3SOCK DISPLAY"; }
          # Kill tmux so all shell environments contain sway-related environment variables
          { command = "tmux kill-server"; }
          { command = "systemctl is-active syncthing.service && systemctl --user start syncthing-tray.service"; always = true; }
          { command = "systemctl --user is-active waybar || systemctl --user restart waybar"; always = true; }
        ];
      };
      extraConfig = ''
        ${appleKeyboardConfig}
        # Any future keyboard xkb_options overrides need to go here
        bindgesture swipe:4:right workspace prev
        bindgesture swipe:4:left workspace next
        bindgesture swipe:3:right focus left
        bindgesture swipe:3:left focus right
        bindswitch lid:off output * power off
        # Middle-click on a window title bar kills it
        bindsym button2 kill
        bindsym --locked ${mod}+o output eDP-1 toggle
        bindsym --locked ${mod}+shift+o output eDP-1 power toggle
        bindsym --locked ${mod}+shift+delete exec systemctl suspend-then-hibernate
        for_window [title=".*"] inhibit_idle fullscreen
        for_window [app_id=org.gnome.Calculator] floating enable
        for_window [class=REAPER] floating enable
        for_window [app_id=nmtui] floating enable
        for_window [app_id=qalculate-gtk] floating enable
        for_window [app_id=\.?blueman-manager(-wrapped)?] floating enable, resize set width 80 ppt height 80 ppt, move position center
        for_window [app_id=nixos_rebuild_log] floating enable, resize set width 80 ppt height 80 ppt, move position center
        for_window [app_id=btop] floating enable, resize set width 80 ppt height 80 ppt, move position center
        for_window [app_id=pavucontrol] floating enable, resize set width 80 ppt height 80 ppt, move position center
        for_window [app_id=org.keepassxc.KeePassXC] floating enable, resize set width 80 ppt height 80 ppt, move position center
        for_window [app_id=org.rncbc.qpwgraph] floating enable
        for_window [app_id=nnn] floating enable
        for_window [app_id=gnome-disks] floating enable
        # Workaround for Bitwig moving itself to current workspace when scale changes
        for_window [app_id=obsidian] move container to workspace 3
        for_window [app_id=org.libretro.RetroArch] move container to workspace 4
        for_window [class=com.bitwig.BitwigStudio] move container to workspace 4
        for_window [class=Kodi] move container to workspace 5
        for_window [app_id=audacious] floating enable, resize set width 80 ppt height 80 ppt, move position center
      '';
      swaynag = {
        enable = true;
        settings = {
          warning = rec {
            background = theme.bgx;
            button-background = theme.bg1x;
            details-background = theme.bg1x;
            text = theme.fgx;
            button-text = theme.fgx;
            border = theme.bg2x;
            border-bottom = theme.bg3x;
            border-bottom-size = 3;
            button-border-size = 1;
          };
          error = rec {
            background = theme.bgx;
            button-background = theme.bg1x;
            details-background = theme.bg1x;
            text = theme.fgx;
            button-text = theme.fgx;
            border = theme.bg2x;
            border-bottom = theme.redx;
            border-bottom-size = 3;
            button-border-size = 1;
          };
        };
      };
    };

    systemd.user.services = {
      swayidle.Service.ExecStop = lib.getExe (pkgs.writeShellApplication {
        name = "swayidle-cleanup";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          BLOCKFILE="$HOME/.local/share/idle-sleep-block"
          if test -f "$BLOCKFILE"; then
            rm "$BLOCKFILE"
          fi
        '';
      });

      polkit-gnome = {
        Unit = {
          Description = "GNOME polkit authentication agent";
        };
        Service = {
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };

      syncthing-tray = {
        Unit = {
          Description = "Simple tray for syncthing file sync service";
        };
        Service = {
          ExecStart = "${lib.getExe pkgs.syncthing-tray} -api '${systemConfig.services.syncthing.settings.gui.apikey}'";
          Restart = "always";
        };
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
      };

      record-playback = {
        Unit = {
          Description = "Records playback from default pulseaudio monitor";
        };
        Service = {
          RuntimeMaxSec = 60;
          Type = "forking";
          ExecStart = lib.getExe (pkgs.writeShellApplication {
            name = "record-playback-exec-start";
            runtimeInputs = [ pkgs.pulseaudio pkgs.coreutils-full pkgs.libnotify ];
            text = ''
              SAVEDIR="$HOME/sync/playback"
              mkdir -p "$SAVEDIR"
              SAVEPATH="$SAVEDIR/$(date +%Y-%m-%dT%H:%M:%S%Z).wav"
              notify-send "Starting audio recording..."
              parecord --device=@DEFAULT_MONITOR@ "$SAVEPATH" &
            '';
          });
          ExecStopPost = lib.getExe (pkgs.writeShellApplication {
            name = "record-playback-exec-stop-post";
            runtimeInputs = [ pkgs.libnotify ];
            text = ''
              if [ "$EXIT_STATUS" -eq 0 ]; then
                notify-send "Stopped recording successfully"
              else
                notify-send --urgency=critical "Recording failed"
              fi
            '';
          });
          Restart = "no";
        };
      };
    };

    services = {
      swayidle = {
        enable = true;
        # Waits for commands to finish (-w) by default
        events = [
          {
            event = "before-sleep";
            command = lib.getExe (pkgs.writeShellApplication {
              name = "swayidle-before-sleep";
              text = lib.optionalString cfg.lockBeforeSleep ''
                ${lib.getExe pkgs.swaylock} --daemonize
              '' + ''
                ${lib.getExe pkgs.tmux-snapshot}
                swaymsg 'output * power off'
              '';
            });
          }
          {
            event = "after-resume";
            command = lib.getExe (pkgs.writeShellApplication {
              name = "swayidle-after-resume";
              text = ''
                if [ -f "$HOME/.local/share/pomo" ]; then pomo start || true; fi
                ${pkgs.sway}/bin/swaymsg 'output * power on'
              '';
            });
          }
        ];
        timeouts = lib.mkIf cfg.idleSleep.enable [
          {
            timeout = cfg.idleSleep.timeout;
            command = lib.getExe (pkgs.writeShellApplication {
              name = "swayidle-sleepy-sleep";
              runtimeInputs = [ pkgs.systemd pkgs.playerctl pkgs.gnugrep pkgs.acpi ];
              text = ''
                if test -f "$HOME/.local/share/idle-sleep-block"; then
                  echo "Restarting service because of idle-sleep-block file"
                  systemctl --restart swayidle.service
                elif playerctl status | grep -q "Playing"; then
                  echo "Restarting service because music is playing"
                  systemctl --restart swayidle.service
                elif acpi --ac-adapter | grep -q "on-line"; then
                  echo "Restarting service because laptop is plugged in"
                  systemctl --restart swayidle.service
                else
                  echo "Idle timeout reached. Night night."
                  if ${builtins.toString cfg.idleSleep.lock}; then
                    swaylock --daemonize
                  fi
                  systemctl ${cfg.idleSleep.sleepType}
                fi
              '';
            });
          }
        ];
        systemdTarget = "sway-session.target";
      };

      wlsunset = {
        enable = true;
        systemdTarget = lib.mkDefault "sway-session.target";
        latitude = "38";
        longitude = "-124";
        temperature = {
          day = 6500;
          night = 3500;
        };
      };

      mako = {
        enable = true;
        anchor = "bottom-right";
        font = "FiraMono Nerd Font 10";
        extraConfig = ''
          sort=-time
          layer=overlay
          width=300
          height=110
          border-radius=5
          icons=1
          max-icon-size=64
          default-timeout=30000
          ignore-timeout=1
          padding=14
          margin=20
          background-color=${theme.bg}

          [urgency=low]
          border-color=${theme.blue}

          [urgency=normal]
          border-color=${theme.bg3}

          [urgency=high]
          border-color=${theme.red}
        '';
      };
    };

    programs.swaylock = {
      enable = true;
      settings = {
        color = theme.bgx;
        image = lib.mkIf (cfg.wallpaper != null) "${cfg.wallpaper}";
        font-size = 24;
        indicator-idle-visible = false;
        indicator-radius = 100;
        show-failed-attempts = true;
      };
    };

    programs.waybar = {
      enable = true;
      style = ''
        @define-color bg ${theme.bg};
        @define-color bgOne ${theme.bg1};
        @define-color bgTwo ${theme.bg2};
        @define-color bgThree ${theme.bg3};
        @define-color red ${theme.red};
        ${builtins.readFile ./waybar.css}
      '';
      # Stopped working when switching between Cinnamon and Sway
      # [error] Bar need to run under Wayland
      # GTK4 get_default_display was saying it was still X11
      systemd = {
        enable = true;
        target = "sway-session.target";
      };
      settings = [{
        layer = "top";
        position = "bottom";
        height = 20;
        modules-left = [
          "sway/workspaces"
          "tray"
          "custom/pomo"
          "custom/idlesleep"
        ];
        modules-center = [ "sway/mode" ];
        modules-right = [
          "custom/rebuild"
          "network#1"
          "network#2"
          "cpu"
          "backlight"
          "custom/wlsunset"
          "custom/recordplayback"
          "wireplumber"
          "bluetooth"
          "battery"
          "clock"
        ];
        "custom/pomo" = {
          format = "{} 󱎫";
          exec = "${pkgs.pomo}/bin/pomo clock";
          interval = 1;
          on-click = "${pkgs.pomo}/bin/pomo pause";
          on-click-right = "${pkgs.pomo}/bin/pomo stop";
        };
        "custom/rebuild" = {
          format = "{}";
          max-length = 25;
          interval = 2;
          exec = "if test -f \"$HOME/tmp/rebuild/status\"; then echo \"$(< $HOME/tmp/rebuild/status)\"; else echo ; fi";
          on-click = viewRebuildLogCmd;
        };
        "custom/recordplayback" = {
          format = "{}";
          max-length = 3;
          interval = 2;
          exec = lib.getExe (pkgs.writeShellApplication {
            name = "waybar-record-playback";
            text = ''
              if systemctl --user is-active --quiet record-playback.service; then
                echo "🔴";
              fi
            '';
          });
        };
        "custom/idlesleep" = {
          format = "{}";
          max-length = 2;
          interval = if cfg.idleSleep.enable then 2 else 0;
          # 󱥑 󱥐 octahedron
          # 󰦞 󰦝 shield
          # 󱓣 󰜗 snowflake
          exec = if cfg.idleSleep.enable then "if test -f \"$HOME/.local/share/idle-sleep-block\"; then echo '󱓣'; else echo '󰜗'; fi" else "echo '󱓣'";
          on-click = lib.getExe (pkgs.writeShellApplication {
            name = "toggle-idle-sleep-lock";
            runtimeInputs = [ pkgs.coreutils ];
            text = ''
              BLOCKFILE="$HOME/.local/share/idle-sleep-block"
              if test -f "$BLOCKFILE"; then
                rm "$BLOCKFILE"
              else
                touch "$BLOCKFILE"
              fi
            '';
          });
        };
        "custom/wlsunset" = {
          exec = "if systemctl --user --quiet is-active wlsunset.service; then echo ''; else echo ''; fi";
          interval = 2;
          on-click = "${lib.getExe pkgs.toggle-service} wlsunset";
          # This doesn't actually work because the only way to have dynamic tooltips is to use json mode
          # tooltip-format = "${pkgs.writers.writeFish "wlsunset-temp" ''
          #   journalctl --user -ex --unit wlsunset.service | tail | string match --regex "\d{4} K" | tail -1
          # ''}";
        };
        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "term";
            "2" = "www";
            "3" = "notes";
            "4" = "arts";
            "5" = "media";
          };
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };
        cpu = {
          interval = 10;
          format = "{usage} ";
          on-click = "foot --app-id=system_monitor btop";
        };
        memory = {
          interval = 30;
          format = "{} ";
        };
        disk = {
          interval = 30;
          format = "{percentage_used} ";
        };
        bluetooth = {
          format = "";
          format-on = "󰂲";
          on-click = "blueman-manager";
        };
        "network#1" = {
          max-length = 60;
          interface = "wl*";
          # format = "{ifname}";
          # format-ethernet = "{ifname} ";
          format-disconnected = "";
          format-wifi = "";
          tooltip-format = "{essid} {frequency}GHz {signalStrength}%";
          on-click = "foot --app-id=nmtui nmtui";
        };
        "network#2" = {
          max-length = 60;
          interface = "pvpn*";
          format = "";
          tooltip-format = "{essid}";
          format-disconnected = "";
          on-click = "foot --app-id=nmtui nmtui";
        };
        wireplumber = {
          format = "{node_name} {volume} {icon}";
          format-muted = "{volume} ";
          format-icons = { default = [ "" "" ]; };
          on-click = "pavucontrol";
          on-click-right = "cycle-pulse-sink";
          on-click-middle = "helvum";
          max-volume = 100;
          scroll-step = 5;
        };
        clock = {
          format = "{:%I:%M %p} 󱛡";
          format-alt = "{:%a %b %d} 󱛡";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        battery = {
          format = "{capacity} {icon}";
          format-charging = "{capacity} ";
          format-icons = [ "" "" "" "" "" ];
          max-length = 40;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        backlight = {
          interval = 5;
          format = "{percent} {icon}";
          format-icons = [ "" "" "" ];
        };
      }];
    };
  };
}
