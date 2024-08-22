{ pkgs, ... }: {
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
  home.username = "stel";
  home.homeDirectory = "/Users/stel";
  home.stateVersion = "24.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;
  programs.fish.shellAbbrs.rebuild = "home-manager switch --flake \"$HOME/nixos-config#marlene\"";
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Macchiato";
    font = {
      size = 18;
      name = "FiraMono Nerd Font Mono";
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
      # Fixes flashing big text when using multiple monitors in sway with different scales
      resize_draw_strategy scale

      clear_all_shortcuts yes
      map ctrl+Shift+c send_text all \x03
      map ctrl+c copy_to_clipboard
      map ctrl+v paste_from_clipboard
      # Standard copy/paste keymaps for MacOS
      map super+c copy_to_clipboard
      map super+v paste_from_clipboard
      map kitty_mod+equal     change_font_size all 13.0
      map kitty_mod+plus     change_font_size all +1.0
      map kitty_mod+minus     change_font_size all -1.0
    '';
  };
}
