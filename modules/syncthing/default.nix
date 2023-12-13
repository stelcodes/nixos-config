{ pkgs, lib, config, ... }:
let
  cfg = config.services.syncthing;
  dataDir = "/home/${config.admin.username}/sync";
  secretKey = "st:${config.admin.username}@${config.networking.hostName}";
  staggeredVersioning = {
    type = "staggered";
    params = {
      cleanInterval = "43200"; # Cleanup versions every 12 hours
      maxAge = "31536000"; # Keep versions for up to a year
    };
  };
  allDevices = {
    framework = {
      id = "G5Q3Q2S-6UCPWME-FPX4RSD-3AWNHAV-36BCGNE-HQ6NEV2-2LWC2MA-DUVQDQZ";
    };
    macbook = {
      id = "JUABVAR-HLJXGIQ-4OZHN2G-P3WJ64R-D77NR74-SOIIEEC-IL53S4S-BO6R7QE";
    };
    meshify = {
      id = "HXMLVPE-DYRLXGQ-ZYBP7UK-G5AWL4U-B27PDUB-7EQHQY4-SZLROKY-4P54XQV";
    };
  };
  allOtherDevices = builtins.removeAttrs allDevices [ config.networking.hostName ];
  allOtherDevicesNames = builtins.attrNames allOtherDevices;
  allFolders = {
    default = {
      versioning = staggeredVersioning;
      path = "${dataDir}/default";
      devices = allOtherDevicesNames;
    };
  };
in
{
  options = {
    services.syncthing.selectedFolders = lib.mkOption {
      description = "Folders to sync with syncthing";
      type = lib.types.either (lib.types.enum [ "all" ]) (lib.types.listOf (lib.types.enum (builtins.attrNames allFolders)));
      default = [ ];
    };
  };
  config = {
    users.users.${config.admin.username}.packages = [ pkgs.syncthing ];
    services = {
      syncthing = {
        inherit dataDir;
        openDefaultPorts = true;
        user = config.admin.username;
        configDir = "/home/${config.admin.username}/.config/syncthing";
        guiAddress = "127.0.0.1:8384";
        settings = {
          options = {
            # urSeen and urAccepted don't seem to stop the popup but they are absolutely the right settings
            urSeen = 3;
            urAccepted = -1;
          };
          gui = {
            user = config.admin.username;
            password = secretKey;
            apikey = secretKey;
          };
          folders = if (cfg.selectedFolders == "all") then allFolders else lib.getAttrs cfg.selectedFolders allFolders;
          devices = allOtherDevices;
        };
      };
    };
  };
}
