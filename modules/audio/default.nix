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
      baseConfig = {

        # https://github.com/robbert-vdh/yabridge?tab=readme-ov-file#performance-tuning
        boot.kernelParams = [ "preempt=full" ];

        # https://discourse.nixos.org/t/nixos-and-linux-pro-audio/1788
        security.pam.loginLimits = [
          { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
          { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
          { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
          { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
        ];

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

      };
      realtimeConfig = {

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
            packages = pkgs.unstable.linuxPackages-rt_latest; # Get the latest bc the rt versions lag behind
          };
          rtirq.enable = false;
          soundcardPciId = config.sound.realtime.soundcardPciId;
        };

      };
    in
    lib.mkIf config.profile.audio (lib.mkMerge [
      baseConfig
      (lib.mkIf (config.sound.realtime.enable && !config.sound.realtime.specialisation) realtimeConfig)
      (lib.mkIf (config.sound.realtime.enable && config.sound.realtime.specialisation) {
        specialisation.realtime-audio.configuration = realtimeConfig;
      })
    ]);

}
