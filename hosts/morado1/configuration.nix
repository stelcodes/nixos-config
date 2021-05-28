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
    enable = true;
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
    disableRegistration = true;
    settings = {
      api = { ENABLE_SWAGGER = false; };
      repository = {
        DISABLE_HTTP_GIT = true;
        DEFAULT_BRANCH = "main";
      };
      ui = { DEFAULT_THEME = "arc-green"; };
      security = {
        INSTALL_LOCK = true;
        SECRET_KEY =
          "IvDiP5wNKoNkYg7rlmHfQZVxAOCl6xYPorYXV4t746GQ7GNlMYiarqcKCsqUXFNT";
      };
      mail = {
        ENABLES = true;
        FROM = "gitea@git.stel.codes";
        MAILER_TYPE = "smtp";
        HOST = "smtp.mailgun.org:587";
        IS_TLS_ENABLED = true;
        USER = "postmaster@sandbox6b576e2e5db145fa8a2833aebe918517.mailgun.org";
        PASSWORD = "0450caa70c93fe11c7c0b782915954ca-fa6e84b7-0e581df9";
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    users.stel = { config, ... }:
      pkgs.lib.mkMerge [ (import /home/stel/config/home-manager pkgs) ];
  };

}
