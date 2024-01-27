{ pkgs, lib, config, inputs, ... }: {

  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  options = {

    sound.realtime = {
      enable = lib.mkEnableOption "Enable realtime specialisation";

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

  config = lib.mkIf config.profile.audio {

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
          (lib.makeSearchPath format [
            "$HOME/.nix-profile/lib"
            "/run/current-system/sw/lib"
            "/etc/profiles/per-user/$USER/lib"
          ])
          + ":$HOME/.${format}";
      in
      {
        DSSI_PATH = makePluginPath "dssi";
        LADSPA_PATH = makePluginPath "ladspa";
        LV2_PATH = makePluginPath "lv2";
        LXVST_PATH = makePluginPath "lxvst";
        VST_PATH = makePluginPath "vst";
        VST3_PATH = makePluginPath "vst3";
        CLAP_PATH = makePluginPath "clap";
      };

    specialisation = lib.mkIf config.sound.realtime.enable {

      realtime-audio.configuration = {

        # https://github.com/mixxxdj/mixxx/wiki/Adjusting-Audio-Latency
        boot.kernelParams = [ "nosmt" ];

        services.tlp.settings = {
          RUNTIME_PM_DISABLE = config.sound.soundcardPciId;
        };


        environment.etc =
          let
            quant = builtins.toString config.sound.realtime.quant;
            json = pkgs.formats.json { };
          in
          {
            # NOTE: Every setup is different, and a lot of factors determine your final
            # latency, like CPU speed, RT/PREEMPTIVE kernels and soundcards supporting
            # different audio formats. That's why 32/48000 isn't always a value that's
            # going to work for everyone. The best way to get everything working is to
            # keep increasing the quant value until you get no crackles (underruns) or
            # until you get audio again (in case there wasn't any). This won't
            # guarantee the lowest possible latency, but will provide a decent one
            # paired with stable audio.
            # default.clock.quantum = 32
            # https://nixos.wiki/wiki/PipeWire
            "pipewire/pipewire.conf.d/92-low-latency.conf".text = ''
              context.properties = {
                default.clock.rate = 48000
                default.clock.quantum = ${quant}
                default.clock.min-quantum = ${quant}
                default.clock.max-quantum = ${quant}
              }
            '';
            "pipewire/pipewire-pulse.d/92-low-latency.conf".source = json.generate "92-low-latency.conf" {
              context.modules = [
                {
                  name = "libpipewire-module-protocol-pulse";
                  args = {
                    pulse.min.req = "${quant}/48000";
                    pulse.default.req = "${quant}/48000";
                    pulse.max.req = "${quant}/48000";
                    pulse.min.quantum = "${quant}/48000";
                    pulse.max.quantum = "${quant}/48000";
                  };
                }
              ];
              stream.properties = {
                node.latency = "${quant}/48000";
                resample.quality = 1;
              };
            };
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
    };
  };

}
