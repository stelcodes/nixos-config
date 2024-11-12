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
  wallpaper = {
    rei-moon = super.fetchurl {
      url = "https://i.imgur.com/NnXQqDZ.jpg";
      hash = "sha256-yth6v4M5UhXkxQ/bfd3iwFRi0FDGIjcqR37737D8P5w=";
    };
    halcyondaze = super.fetchurl {
      url = "https://i.imgur.com/obIghpJ.png";
      hash = "sha256-ar+Zbf/DN7bc9tAnQFi6qR8TPoBREzCb3d65HoOez5s=";
    };
    anime-girl-cat = super.fetchurl {
      url = "https://i.imgur.com/sCV0yu7.jpg";
      hash = "sha256-qDt+Gj21M2LkMo80sXICCzy/LjOkAqeN4la/YhaLBmM=";
    };
    anime-girl-coffee = super.fetchurl {
      url = "https://i.imgur.com/lR2iapT.jpg";
      hash = "sha256-JtY6vWns88mZ29fuYBYZO1NoD+O1YxPb9EBfotv7yb0=";
    };
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
  tmux-startup = super.writeShellApplication {
    name = "tmux-startup";
    text = ''
      if tmux run 2>/dev/null; then
        tmux new-window -t sandbox:
        tmux new-session -As sandbox
      else
        tmux new-session -ds config -c "$HOME/nixos-config"
        tmux new-session -ds media
        tmux new-session -As sandbox
      fi
    '';
  };
  devflake = super.writeShellApplication {
    name = "devflake";
    text = ''
      # Create flake.nix for dev environment from gist template and setup direnv
      if [ -e flake.nix ]; then
        printf "ERROR: Nix flake already exists"
        exit 1
      fi
      if [ ! -d .git ]; then
        printf "ERROR: CWD is not a git repository"
        exit 1
      fi
      # git status --porcelain only prints something if worktree is dirty
      if [ -n "$(git status --porcelain)" ]; then
        printf "ERROR: Git working tree is dirty"
        exit 1
      fi
      tmpfile="$(mktemp)"
      gh gist view -r | tee "$tmpfile"
      read -rp "Press enter to create this flake.nix or ctrl+c to quit"
      state="garbage"
      while IFS= read -r line; do
        if [ "$state" = "garbage" ] && [ -z "$line" ]; then
          state="gist"
        fi
        if [ "$state" = "gist" ]; then
          printf "%s\n" "$line" >> flake.nix
        fi
      done < "$tmpfile"
      rm "$tmpfile"
      if [ ! -e flake.nix ]; then
        printf "ERROR: flake.nix was not created"
        exit 1
      fi
      git add flake.nix
      nix flake lock
      printf 'use flake' > .envrc
      git add flake.lock .envrc
      git commit -m "Add Nix flake and direnv integration"
      direnv allow
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
  makeFirefoxApp = title: url: (super.writeShellApplication {
    name = super.lib.replaceStrings [ " " ] [ "-" ] (super.lib.toLower title);
    runtimeInputs = [ super.coreutils-full super.ripgrep super.firefox super.sway ];
    text = ''
      app_title="${title}"
      app_url="${url}"
      temp_title="${title}FirefoxAppTempWindow"
      temp_file="/tmp/$temp_title.html" # Must be static to remember popup preferences
      count_firefoxes() { swaymsg -t get_tree | rg -c '"name": ".* — Mozilla Firefox",'; }
      initial_firefoxes="$(count_firefoxes)"
      # Create html page that will open our main app as a popup
      printf '<head><title>%s</title></head><script>window.open("%s", "%s", "popup")</script>' \
        "$temp_title" "$app_url" "$app_title" > "$temp_file"
      swaymsg "$(printf 'for_window [title="%s — Mozilla Firefox"] move window to scratchpad' "$temp_title")"
      firefox --new-window "$temp_file"
      counter=0
      sleep 1 # Give firefox time to spawn popup window
      # Wait until there are two new firefox windows open to close the temp window
      while test "$(count_firefoxes)" -lt "$((initial_firefoxes+2))"; do
        if test "$counter" -eq 0; then
          # Try to show the temp window so the user can enable permissions
          swaymsg "$(printf '[title="%s — Mozilla Firefox"] focus' "$temp_title")" \
            || echo "Failed to focus temporary firefox window"
        fi
        sleep 1 # Wait for popup permissions to be granted
        counter="$((counter+1))"
        # Give up trying to close the temporary window after 30 seconds
        if test "$counter" -gt 30; then
          exit 0
        fi
      done
      swaymsg "$(printf '[title="%s — Mozilla Firefox"] kill' "$temp_title")"
    '';
  });
  discord-firefox = self.makeFirefoxApp "Discord" "https://discord.com/app";
  spotify-firefox = self.makeFirefoxApp "Spotify" "https://open.spotify.com";
  kodi-loaded = super.kodi.withPackages (p: [
    p.visualization-goom
    p.somafm
    p.radioparadise
    p.joystick
    p.youtube
  ]);
  retroarch-loaded = super.retroarch.override {
    settings = {
      menu_driver = "xmb";
      xmb_menu_color_theme = "15"; # cube purple
      assets_directory = "${super.retroarch-assets}/share/retroarch/assets";
      savefile_directory = "~/sync/games/saves";
      savestate_directory = "~/sync/games/states";
      screenshot_directory = "~/sync/games/screenshots";
      playlist_directory = "~/sync/games/playlists";
      thumbnails_directory = "~/sync/games/thumbnails";
      content_favorites_path = "~/sync/games/content_favorites.lpl";
      playlist_entry_remove_enable = "0";
      playlist_entry_rename = "false";
      input_menu_toggle_gamepad_combo = "7"; # hold start for quick menu
      menu_swap_ok_cancel_buttons = "true";
      auto_overrides_enable = "true"; # Auto setup controllers
      auto_remaps_enable = "true"; # Auto load past remaps
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
  mako = super.mako.overrideAttrs (final: prev: {
    preFixup = ''
      gappsWrapperArgs+=(
        --prefix PATH : "${super.lib.makeBinPath [ super.systemd /* for busctl */ super.jq super.bash ]}"
      )
    '';
  });
  firejailWrapper = { executable, desktop ? null, profile ? null, extraArgs ? [ ] }: super.runCommand "firejail-wrap"
    {
      preferLocalBuild = true;
      allowSubstitutes = false;
      meta.priority = -1; # take precedence over non-firejailed versions
    }
    (
      let
        firejailArgs = super.lib.concatStringsSep " " (
          extraArgs ++ (super.lib.optional (profile != null) "--profile=${toString profile}")
        );
      in
      ''
        command_path="$out/bin/$(basename ${executable})-jailed"
        mkdir -p $out/bin
        mkdir -p $out/share/applications
        cat <<'_EOF' >"$command_path"
        #! ${super.runtimeShell} -e
        exec /run/wrappers/bin/firejail ${firejailArgs} -- ${toString executable} "\$@"
        _EOF
        chmod 0755 "$command_path"
      '' + super.lib.optionalString (desktop != null) ''
        substitute ${desktop} $out/share/applications/$(basename ${desktop}) \
          --replace ${executable} "$command_path"
      ''
    );
  obsidian-jailed = self.firejailWrapper {
    executable = "${super.unstable.obsidian}/bin/obsidian";
    desktop = "${super.unstable.obsidian}/share/applications/obsidian.desktop";
    extraArgs = [ "--noprofile" "--whitelist=\"$HOME/notes\"" "--whitelist=\"$HOME/.config/obsidian\"" ];
  };
  desktop-entries = super.writeShellApplication {
    name = "desktop-entries";
    runtimeInputs = [ super.coreutils-full super.findutils ];
    text = ''
      data_dirs="$XDG_DATA_DIRS:$HOME/.local/share"
      matches=""
      for p in ''${data_dirs//:/ }; do
        printf -v matches "%s%s" "$matches" "$(find "$p/applications" -name '*.desktop' 2>/dev/null || true)"
      done
      printf "%s" "$matches" | sort | uniq
    '';
  };
  git-fiddle = super.callPackage ./git-fiddle.nix { };
  convert-audio = super.callPackage ./convert-audio { };
  rekordbox-add = super.callPackage ./rekordbox-add { };
}
