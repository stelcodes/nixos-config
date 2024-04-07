{ pkgs, lib, config, ... }:
let
  cfg = config.services.syncthing;
  dataDir = "/home/${config.admin.username}/sync";
  secretKey = "sync4life";
  # https://docs.syncthing.net/users/versioning
  # cleanupIntervalS must be int, params must be strings
  # Debug with journalctl -exf --unit syncthing-init.service
  staggeredMonth = {
    type = "staggered";
    cleanupIntervalS = 86400; # Once every day
    params = {
      maxAge = "2592000"; # Keep versions for up to a month
    };
  };
  trashcanBasic = {
    type = "trashcan";
    cleanupIntervalS = 86400; # Once every day
    params = {
      cleanoutDays = "7";
    };
  };
  devices = {
    yuffie.id = "G5Q3Q2S-6UCPWME-FPX4RSD-3AWNHAV-36BCGNE-HQ6NEV2-2LWC2MA-DUVQDQZ";
    aerith.id = "JUABVAR-HLJXGIQ-4OZHN2G-P3WJ64R-D77NR74-SOIIEEC-IL53S4S-BO6R7QE";
    terra.id = "HXMLVPE-DYRLXGQ-ZYBP7UK-G5AWL4U-B27PDUB-7EQHQY4-SZLROKY-4P54XQV";
    beatrix.id = "ZZTXMYW-7FC4BBY-4QHAB6R-2RCMQDT-SRTS3F7-ZZSL4WE-27P4Y46-5YC4CAZ";
    celes.id = "2N6LGUP-2YKWX3Z-J2YPY5N-GUS34IL-HKDNOGM-CHWD6EG-6ODSB5F-2GV4GQ7";
  };
  folders = {
    default = {
      versioning = trashcanBasic;
      path = "${dataDir}/default";
      devices = builtins.attrNames devices;
    };
    games = {
      versioning = staggeredMonth;
      path = "${dataDir}/games";
      devices = [ "terra" "beatrix" ];
    };
    notes = {
      versioning = staggeredMonth;
      path = "${dataDir}/notes";
      devices = [ "terra" "celes" "yuffie" "aerith" ];
    };
    secrets = {
      versioning = staggeredMonth;
      path = "${dataDir}/secrets";
      devices = [ "terra" "celes" "yuffie" ];
    };
    tunes = {
      versioning = trashcanBasic;
      path = "${dataDir}/tunes";
      devices = [ "terra" "aerith" "celes" ];
    };
  };
in
{
  options = {
    services.syncthing.selectedFolders = lib.mkOption {
      description = "Folders to sync with syncthing";
      type = lib.types.listOf (lib.types.enum (builtins.attrNames folders));
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    users.users.${config.admin.username}.packages = [ pkgs.syncthing ];
    services = {
      syncthing = {
        inherit dataDir;
        openDefaultPorts = true;
        user = config.admin.username;
        configDir = "/home/${config.admin.username}/.config/syncthing";
        guiAddress = "127.0.0.1:8384";
        settings = {
          inherit devices;
          folders = lib.getAttrs cfg.selectedFolders folders;
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
        };
      };
    };
  };
}
