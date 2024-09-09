{lib, pkgs, config, ...}: {
options = {
    profile = {
      graphical = lib.mkOption {
        type = lib.types.bool;
      };
      battery = lib.mkOption {
        type = lib.types.bool;
      };
      virtual = lib.mkOption {
        type = lib.types.bool;
      };
      virtualHost = lib.mkOption {
        type = lib.types.bool;
      };
      audio = lib.mkOption {
        type = lib.types.bool;
      };
      bluetooth = lib.mkOption {
        type = lib.types.bool;
      };
    };
    activities = {
      gaming = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      coding = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      djing = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      jamming = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
    admin.username = lib.mkOption {
      type = lib.types.str;
      default = "stel";
    };
    admin.email = lib.mkOption {
      type = lib.types.str;
      default = "stel@stel.codes";
    };
    theme.name = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-frappe";
    };
    theme.set = lib.mkOption {
      type = lib.types.attrs;
      default = (import ../../misc/themes.nix pkgs.unstable).${config.theme.name};
    };
  };
}
