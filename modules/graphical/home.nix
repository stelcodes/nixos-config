{ pkgs, config, inputs, lib, ... }:
let
  theme = config.theme.set;
in
{
  config = lib.mkIf config.profile.graphical {

    home = {
      packages = [
        pkgs.material-icons # for mpv uosc
        pkgs.keepassxc
      ];

      # Need to create aliases because Launchbar doesn't look through symlinks.
      # Enable Other in Spotlight to see Nix apps
      activation.link-apps = lib.mkIf pkgs.stdenv.isDarwin (lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        new_nix_apps="${config.home.homeDirectory}/Applications/Nix"
        rm -rf "$new_nix_apps"
        mkdir -p "$new_nix_apps"
        find -H -L "$newGenPath/home-files/Applications" -name "*.app" -type d -print | while read -r app; do
          real_app=$(readlink -f "$app")
          app_name=$(basename "$app")
          target_app="$new_nix_apps/$app_name"
          echo "Alias '$real_app' to '$target_app'"
          ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
        done
      '');
    };

    programs = {
      mpv = {
        enable = true;
        config = {
          # turn off default interface, use uosc instead
          osd-bar = "no";
          border = "no";
          sub-auto = "all";
          demuxer-max-bytes = "2048MiB";
          gapless-audio = "no";
        };
        scripts = let p = pkgs.mpvScripts; in [
          p.uosc
          p.thumbfast
          p.mpv-cheatsheet
          p.videoclip
        ] ++ lib.lists.optionals pkgs.stdenv.isLinux [
          p.mpris
        ];
        # scriptOpts = {
        #   videoclip = {
        #   };
        # };
      };
      kitty = {
        enable = true;
        # https://github.com/kovidgoyal/kitty-themes/tree/master/themes without .conf
        themeFile = theme.kittyThemeFile;
        font = {
          size = 16;
          name = "FiraMono Nerd Font";
          package = (pkgs.nerdfonts.override { fonts = [ "FiraMono" ]; });
        };
        extraConfig = ''
          disable_ligatures never
          shell ${pkgs.fish}/bin/fish
          shell_integration disabled no-cursor
          wheel_scroll_multiplier 5.0
          touch_scroll_multiplier 1.0
          copy_on_select yes
          enable_audio_bell no
          confirm_os_window_close 1
          macos_titlebar_color background
          macos_option_as_alt left
          macos_quit_when_last_window_closed yes

          kitty_mod ctrl+alt
          clear_all_shortcuts yes
          map ctrl+Shift+c send_text all \x03
          map ctrl+c copy_to_clipboard
          map ctrl+v paste_from_clipboard
          # Standard copy/paste keymaps for MacOS
          map super+c copy_to_clipboard
          map super+v paste_from_clipboard
          map kitty_mod+equal change_font_size all 0
          map kitty_mod+plus change_font_size all +1.0
          map kitty_mod+minus change_font_size all -1.0
        '';
      };
    };

  };
}
