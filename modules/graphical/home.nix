{ pkgs, config, inputs, lib, ... }:
let
  theme = config.theme.set;
in
{
  config = lib.mkIf config.profile.graphical {

  };
}
