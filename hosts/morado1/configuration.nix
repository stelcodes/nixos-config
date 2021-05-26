{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    /home/stel/config/modules/common.nix
    /home/stel/config/modules/server.nix
    /home/stel/config/modules/postgresql-local.nix
    <home-manager/nixos>
  ];

  networking.hostName = "morado1";
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts = {
      "git.stel.codes" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:3000";
      };
    };
  };

  services.gitea = {
    enable = false;
    appName = "Stel's Gitea";
    stateDir = "/data/gitea";
    database.type = "postgres";
    dump = {
      enable = true;
      interval = "5:00";
    };
    domain = "git.stel.codes";
    rootUrl = "https://git.stel.codes";
    httpPort = 3000;
    cookieSecure = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    users.stel = { config, ... }:
      pkgs.lib.mkMerge [ (import /home/stel/config/home-manager pkgs) ];
  };

}
