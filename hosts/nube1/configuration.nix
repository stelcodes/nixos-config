{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    /home/stel/config/modules/common.nix
    (import "${
        builtins.fetchTarball
        "https://github.com/rycee/home-manager/archive/master.tar.gz"
      }/nixos")
  ];

  boot.cleanTmpDir = true;
  networking = {
    hostName = "nube1";
    firewall = {
      allowPing = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  users = {
    users = {
      stel.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl1QCu19AUDFaaZZAt4YtnxxdX+JDvDz5rdnBEfH/Bb stel@azul"
      ];
    };
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "cms.stel.codes" = {
          enableACME = true;
          forceSSL = true;
          proxyPass = "http://localhost:8055";
        };
        "stel.codes" = {
          enableACME = true;
          forceSSL = true;
          root = "/www/dev-blog";
        };
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    users.stel = { config, ... }:
      pkgs.lib.mkMerge [
        (import /home/stel/config/home-manager pkgs)
        # (import /home/stel/config/home-manager/python pkgs)
        # (import /home/stel/config/home-manager/rust pkgs)
        # (import /home/stel/config/home-manager/go pkgs)
        # (import /home/stel/config/home-manager/nodejs pkgs)
        # (import /home/stel/config/home-manager/clojure pkgs)
      ];
  };
}
