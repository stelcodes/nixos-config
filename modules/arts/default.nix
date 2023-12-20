{ pkgs, lib, config, inputs, ... }: {

  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  options = {

    hardware.soundcardPciId = lib.mkOption {
      description = "Find with lspci | grep Audio";
      type = lib.types.str;
    };

  };

  config = {

    # https://github.com/musnix/musnix
    musnix = {
      enable = (config.activities.jamming or config.activities.djing);
      alsaSeq.enable = true;
      ffado.enable = true;
      kernel = {
        # realtime = true; # Maybe this is pointless? https://github.com/musnix/musnix/issues/118
        # packages = pkgs.linuxPackages_rt_6_1;
      };
      # rtirq.enable = true;
      soundcardPciId = config.hardware.soundcardPciId;
    };

  };

}
