{ pkgs, lib, ... }: {
  profile = {
    graphical = false;
    battery = false;
    virtual = false;
    virtualHost = false;
    audio = false;
    bluetooth = false;
  };
  activities.coding = true;
  theme.name = "catppuccin-macchiato";
  home = {
    username = "stel";
    homeDirectory = "/Users/stel";
    stateVersion = "24.05"; # Please read the comment before changing.
    packages = [
      pkgs.material-icons # for mpv uosc
      pkgs.audacity
      pkgs.keepassxc
    ];
  };
  programs = {
    home-manager.enable = true;
    fish.shellAbbrs.rebuild = "home-manager switch --flake \"$HOME/nixos-config#marlene\"";
    mpv = {
      enable = true;
      config = {
        # turn off default interface, use uosc instead
        osd-bar = "no";
        border = "no";
        sub-auto= "all";
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
      theme = "Catppuccin-Macchiato";
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
        # Fixes flashing big text when using multiple monitors in sway with different scales
        resize_draw_strategy scale

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
}

