{ pkgs, lib, hostName, adminName, config, ... }:
let
  cfg = config.services.syncthing;
  dataDir = "/home/${adminName}/sync";
  secretKey = "st:${adminName}@${hostName}";
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
  };
  allOtherDevices = builtins.removeAttrs allDevices [ hostName ];
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
      type = lib.types.listOf (lib.types.enum (builtins.attrNames allFolders));
      default = [ ];
    };
  };
  config = {
    services = {
      syncthing = {
        openDefaultPorts = true;
        user = adminName;
        configDir = "/home/${adminName}/.config/syncthing";
        # Ughhhhh I wish the NixOS syncthing module supported unix sockets
        # guiAddress = "/tmp/st.sock";
        guiAddress = "127.0.0.1:8384";
        settings = {
          options = {
            urSeen = 3;
            urAccepted = -1;
          };
          gui = {
            user = adminName;
            password = secretKey;
            apikey = secretKey;
          };
          folders = lib.getAttrs cfg.selectedFolders allFolders;
          devices = allOtherDevices;
        };
      };
    };
  };
}