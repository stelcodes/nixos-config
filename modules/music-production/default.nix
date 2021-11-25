{ pkgs, ... }: {
  config = {
    environment.systemPackages = with pkgs; [
      carla
      surge
      # bristol
      a2jmidid
      unstable.ardour
      audacity
    ];
  };
}
