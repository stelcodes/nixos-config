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
          locations."/".proxyPass = "http://localhost:8055";
        };
        "stel.codes" = {
          enableACME = true;
          forceSSL = true;
          serverAliases = [ "www.stel.codes" ];
          locations."/".root = "/www/dev-blog";
        };
      };
    };

    postgresql = {
      enable = true;
      package = pkgs.postgresql_13;
      enableTCPIP = true;
      port = 5432;
      dataDir = "/data/postgres";
      authentication = pkgs.lib.mkOverride 10 ''
        # I'm setting up postgres such that any local connection to the server is trusted.
        # As long as the server isn't exposed to the internet and my OS security is good, this
        # is fine and recommended by the official postgres docs: https://is.gd/RsMMpx

        # Allow any user on the local system to connect to any database with
        # any database user name using Unix-domain sockets (the default for local
        # connections).
        local all all trust

        # The same using local loopback TCP/IP connections.
        host all all 127.0.0.1/32 trust

        # The same over IPv6.
        host all all ::1/128 trust

        # The same using a host name (would typically cover both IPv4 and IPv6).
        host all all localhost trust
      '';
      ensureDatabases = [ "test" "dev_blog" ];
      ensureUsers = [
        {
          name = "stel";
        }
        # ALTER USER stel WITH SUPERUSER;
        # To change password:
        # ALTER USER <user> WITH PASSWORD '<password>';
        {
          name = "dev_blog_directus";
          ensurePermissions = { "DATABASE dev_blog" = "ALL PRIVILEGES"; };
        }
        {
          name = "static_site_builder";
          ensurePermissions = { "ALL TABLES IN SCHEMA public" = "SELECT"; };
          # GRANT SELECT ON ALL TABLES IN SCHEMA public TO static_site_builder;
          # This allows the user to read all tables in the default public schema. BUT not tables created after
          # this command was run.
          # Schema's are basically namespaces for tables in postgres
          # The above command works for old tables, but static_site_builder doesn't have permission for new tables
          # We need to change the default privileges for objects created by dev_blog_directus.
          # The way default privileges work in postgres is this: only a user can change their own default privileges
          # on *their own* objects. So the dev_blog_directus user has to change their default privileges to allow
          # static_site_builder to SELECT on new dev_blog_directus tables.
          # As dev_blog_directus user:
          # ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO static_site_builder;
        }
      ];
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
        (import /home/stel/config/home-manager/clojure pkgs)
      ];
  };
}
