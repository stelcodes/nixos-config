{ pkgs, ... }: {
  home = {
    stateVersion = "23.11";
    packages = [ ];
  };
  wayland.windowManager.sway.config.input."type:keyboard".xkb_options = "caps:escape";
}
