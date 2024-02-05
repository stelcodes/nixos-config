{ pkgs, lib, config, inputs, ... }: {

  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  options = {

    sound.realtime = {
      enable = lib.mkEnableOption "Enable realtime specialisation";

      specialisation = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      soundcardPciId = lib.mkOption {
        description = "Find with lspci | grep Audio";
        type = lib.types.str;
      };

      quant = lib.mkOption {
        description = "Quant value for pipewire low latency setup";
        type = lib.types.int;
        default = 100;
      };
    };


  };

  config =
    let
      realtimeConfig = {
        # https://github.com/mixxxdj/mixxx/wiki/Adjusting-Audio-Latency

        services.tlp.settings = {
          RUNTIME_PM_DISABLE = config.sound.realtime.soundcardPciId;
        };

        # https://github.com/musnix/musnix
        musnix = {
          enable = true;
          alsaSeq.enable = true;
          ffado.enable = true;
          kernel = {
            realtime = true; # https://github.com/musnix/musnix/issues/118
            packages = pkgs.linuxPackages_rt_6_1;
          };
          rtirq.enable = true;
          soundcardPciId = config.sound.realtime.soundcardPciId;
        };

      };
    in
    lib.mkIf config.profile.audio ({

      sound.enable = true;

      # Needed for pipewire
      security.rtkit.enable = true;

      hardware = {
        # Use pipewire instead of pulseaudio
        pulseaudio.enable = false;
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      environment.variables =
        let
          makePluginPath = format:
            # Yabridge uses the first entry for installation directory so it needs to be writable
            "$HOME/.${format}:" +
            (lib.makeSearchPath format [
              "$HOME/.nix-profile/lib"
              "/run/current-system/sw/lib"
              "/etc/profiles/per-user/$USER/lib"
            ]);
        in
        lib.mkForce {
          DSSI_PATH = makePluginPath "dssi";
          LADSPA_PATH = makePluginPath "ladspa";
          LV2_PATH = makePluginPath "lv2";
          LXVST_PATH = makePluginPath "lxvst";
          VST_PATH = makePluginPath "vst";
          VST3_PATH = makePluginPath "vst3";
          CLAP_PATH = makePluginPath "clap";
        };

      specialisation = lib.mkIf (config.sound.realtime.enable && config.sound.realtime.specialisation)
        {
          realtime-audio.configuration = realtimeConfig;
        };
    } // (lib.mkIf (config.sound.realtime.enable && !config.sound.realtime.specialisation) realtimeConfig ));

}
