self: super: {
  success-alert = super.fetchurl {
    # https://freesound.org/people/martcraft/sounds/651624/
    url = "https://cdn.freesound.org/previews/651/651624_14258856-lq.mp3";
    sha256 = "urNwmGEG2YJsKOtqh69n9VHdj9wSV0UPYEQ3caEAF2c=";
  };
  failure-alert = super.fetchurl {
    # https://freesound.org/people/martcraft/sounds/651625/
    url = "https://cdn.freesound.org/previews/651/651625_14258856-lq.mp3";
    sha256 = "XAEJAts+KUNVRCFLXlGYPIJ06q4EjdT39G0AsXGbT2M=";
  };
  pomo-alert = super.fetchurl {
    # https://freesound.org/people/dersinnsspace/sounds/421829/
    url = "https://cdn.freesound.org/previews/421/421829_8224400-lq.mp3";
    sha256 = "049x6z6d3ssfx6rh8y11var1chj3x67nfrakigydnj3961hnr6ar";
  };
  nord-wallpaper = super.fetchurl {
    url = "https://raw.githubusercontent.com/dxnst/nord-backgrounds/9334ccc197cf0e4299778fd6ff4202fdbe2756f2/music/3840x2160/bjorkvespertine.png";
    sha256 = "bZQVGQHO+YZ5aVfBdHbEELz1Zu4dBnO33w21nKVoHZ4=";
  };
  pomo = super.callPackage ./pomo.nix { };
  wezterm-nightly = super.callPackage ./wezterm-nightly { };
  gnome-feeds-nightly = super.callPackage ./gnome-feeds-nightly { };
  writeBabashkaScript = super.callPackage ./write-babashka-script.nix { };
  cycle-pulse-sink = self.writeBabashkaScript {
    name = "cycle-pulse-sink";
    text = builtins.readFile ../misc/cycle-pulse-sink.clj;
    runtimeInputs = [ super.pulseaudio ];
  };
  tmux-snapshot = super.writeShellApplication {
    name = "tmux-snapshot";
    runtimeInputs = [ super.coreutils-full super.procps super.hostname super.gnused super.tmux super.gnugrep super.gnutar super.gzip super.findutils ];
    text = ''
      if tmux has-session; then
        echo "tmux is running, saving snapshot..."
        ${super.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh quiet
      else
        echo "tmux is not running"
      fi
    '';
  };
  truecolor-test = super.writeShellApplication {
    name = "truecolor-test";
    runtimeInputs = [ super.coreutils super.gawk ];
    text = ''
      awk 'BEGIN{
          s="/\\/\\/\\/\\/\\"; s=s s s s s s s s s s s s s s s s s s s s s s s;
          for (colnum = 0; colnum<256; colnum++) {
              r = 255-(colnum*255/255);
              g = (colnum*510/255);
              b = (colnum*255/255);
              if (g>255) g = 510-g;
              printf "\033[48;2;%d;%d;%dm", r,g,b;
              printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
              printf "%s\033[0m", substr(s,colnum+1,1);
          }
          printf "\n";
      }'
    '';
  };
  rebuild = super.writeShellApplication {
    name = "rebuild";
    runtimeInputs = [ super.coreutils super.nixos-rebuild ]; # mpv is optional
    text = ''
      LOG_DIR="$HOME/tmp/rebuild"
      STATUS_FILE="$LOG_DIR/status"
      LOG_FILE="$LOG_DIR/$(date +%Y-%m-%dT%H:%M:%S%Z)"
      LOG_LINK="$LOG_DIR/latest"
      CONFIG_DIR="$HOME/nixos-config"

      rebuild() {
        /run/wrappers/bin/doas nixos-rebuild --option eval-cache false switch --flake "$CONFIG_DIR#" 2>&1 | tee "$LOG_FILE";
      }
      succeed() {
        echo "New generation created 🥳" | tee -a "$LOG_FILE";
        echo "" > "$STATUS_FILE";
        mpv ${self.success-alert} || true;
      }
      fail() {
        echo "Something went wrong 🤔" | tee -a "$LOG_FILE";
        echo "" > "$STATUS_FILE";
        mpv ${self.failure-alert} || true;
        exit 1;
      }

      mkdir -p "$LOG_DIR"
      echo "" > "$STATUS_FILE"
      touch "$LOG_FILE"
      ln -sf "$LOG_FILE" "$LOG_LINK";
      if rebuild; then succeed; else fail; fi
    '';
  };

  toggle-service = super.writeShellApplication {
    name = "toggle-service";
    runtimeInputs = [ super.systemd ];
    text = ''
      SERVICE="$1.service"
      if ! systemctl --user cat "$SERVICE" &> /dev/null; then
        echo "ERROR: Service does not exist"
        exit 1
      fi
      if systemctl --user is-active "$SERVICE"; then
        echo "Stopping service"
        systemctl --user stop "$SERVICE"
      else
        echo "Starting service"
        systemctl --user start "$SERVICE"
      fi
    '';
  };
  graillon-free = super.callPackage ./graillon.nix { };
  mixxx = super.symlinkJoin {
    name = "mixxx-wayland";
    paths = [ super.mixxx ];
    buildInputs = [ super.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/mixxx --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+-platform xcb}}"
    '';
  };
  check-newline = super.writeShellApplication {
    name = "check-newline";
    runtimeInputs = [ super.coreutils ];
    text = ''
      filename="$1"
      if [ ! -s "$filename" ]; then
        echo "$filename is empty"
      elif [ -z "$(tail -c 1 <"$filename")" ]; then
        echo "$filename ends with a newline or with a null byte"
      else
        echo "$filename does not end with a newline nor with a null byte"
      fi
    '';
  };
  wg-killswitch = super.writeShellApplication {
    name = "wg-killswitch";
    runtimeInputs = [ super.wireguard-tools super.iptables super.coreutils-full ];
    text = ''
      chain="wg-killswitch"

      enableKillswitch() {
        cmd="$1"
        "$cmd" --new-chain "$chain" >/dev/null 2>&1 || true
        "$cmd" --insert "$chain" ! --out-interface "$name" --match mark ! --mark "$fwmark" --match addrtype ! --dst-type LOCAL --jump DROP
        while "$cmd" --delete "$chain" 2 >/dev/null 2>&1; do true; done
        "$cmd" --check OUTPUT --jump "$chain" || "$cmd" --insert OUTPUT --jump "$chain"
      }

      disableKillswitch() {
        cmd="$1"
        "$cmd" --flush "$chain" >/dev/null 2>&1 || true
      }

      ensureRoot() {
        if [ "$(id -u)" -ne 0 ]; then
          echo "Command must be run as root, aborting"
          exit 1
        fi
      }

      usage() {
        echo "Usage:"
        echo "wg-killswitch enable <interface>"
        echo "wg-killswitch disable"
        echo ""
        echo "Description: Create iptables rules to restrict outgoing traffic to a given wireguard interface"
      }

      arg1="''${1:-""}"
      arg2="''${2:-""}"
      ensureRoot

      if [ "$arg1" = "enable" ] && [ -n "$arg2" ]; then
        name="$arg2"
        echo "Enabling killswitch for interface: $name"
        fwmark="$(wg show "$name" fwmark)"
        enableKillswitch iptables
        enableKillswitch ip6tables
        echo "Enabled killswitch successfully"
        exit 0
      elif [ "$arg1" = "disable" ]; then
        read -rp 'Disable killswitch? (y/n): '
        if [ "$REPLY" != 'y' ]; then
          echo "Disable subcommand aborted"
          exit 1
        fi
        disableKillswitch iptables
        disableKillswitch ip6tables
        echo "Disabled killswitch successfully"
        exit 0
      elif [ "$arg1" = "help" ] || [ "$arg1" = "--help" ]; then
        usage
        exit 0
      fi

      echo "Invalid arguments, aborting"
      echo ""
      usage
      exit 1
    '';
  };
  discord-firefox = super.writeShellApplication {
    name = "discord";
    text = ''
      firefox --new-window 'https://discord.com/app'
    '';
  };
  kodi-loaded = super.kodi.withPackages (p: [
    p.visualization-goom
    p.somafm
    p.radioparadise
    p.joystick
  ]);
  retroarch-loaded = super.retroarch.override {
    settings = {
      menu_driver = "xmb";
      xmb_menu_color_theme = "15"; # cube purple
      savefile_directory = "~/sync/games/saves";
      savestate_directory = "~/sync/games/states";
      screenshot_directory = "~/sync/games/screenshots";
      playlist_directory = "~/sync/games/playlists";
      thumbnails_directory = "~/sync/games/thumbnails";
      content_favorites_path = "~/sync/games/content_favorites.lpl";
      playlist_entry_remove_enable = "0";
      playlist_entry_rename = "false";
    };
    cores = with super.libretro; [
      # pkgs/applications/emulators/retroarch/cores.nix
      mesen # nes
      snes9x # snes
      mupen64plus # n64
      dolphin # gamecube/wii
      swanstation # ps1
      sameboy # gb
      mgba # gba
      ppsspp # psp
    ];
  };
  syncthing-tray = super.syncthing-tray.overrideAttrs (final: prev: {
    meta.mainProgram = "syncthing-tray";
  });
  audacious = super.audacious.overrideAttrs (final: prev: {
    meta.mainProgram = "audacious";
  });
}
