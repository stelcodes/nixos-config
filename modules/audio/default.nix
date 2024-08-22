{ pkgs, lib, config, inputs, ... }: {

  # https://github.com/robbert-vdh/yabridge?tab=readme-ov-file#performance-tuning

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
      cfg = config.sound;
      baseConfig = {

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

        # Get the latest rt kernel bc the rt versions lag behind
        boot.kernelPackages = pkgs.linuxPackages-rt_latest;

        # https://discourse.nixos.org/t/nixos-and-linux-pro-audio/1788
        security.pam.loginLimits = [
          { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
          { domain = "@audio"; item = "rtprio"; type = "-"; value = "99"; }
          { domain = "@audio"; item = "nofile"; type = "soft"; value = "99999"; }
          { domain = "@audio"; item = "nofile"; type = "hard"; value = "99999"; }
        ];

        services.tlp.settings = {
          RUNTIME_PM_DISABLE = lib.mkIf (cfg.realtime.soundcardPciId != null) cfg.realtime.soundcardPciId;
        };

      };
    in
    lib.mkIf config.profile.audio (lib.mkMerge [
      baseConfig
      (lib.mkIf (cfg.realtime.enable && !cfg.realtime.specialisation) realtimeConfig)
      (lib.mkIf (cfg.realtime.enable && cfg.realtime.specialisation) {
        specialisation.realtime-audio.configuration = realtimeConfig;
      })
    ]);

}
