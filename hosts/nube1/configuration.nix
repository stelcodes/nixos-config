{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect
    /config/modules/server
    /config/modules/postgresql/local.nix
    /config/modules/clojure
    /config/modules/nodejs
  ];

  networking.hostName = "nube1";
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];

  services.nginx.enable = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.recommendedTlsSettings = true;
  services.nginx.virtualHosts = {
    "cms.stel.codes" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8055";
    };
    "stel.codes" = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "www.stel.codes" ];
      locations."/".root = "/www/dev-blog-published";
    };
    "preview.stel.codes" = {
      enableACME = true;
      forceSSL = true;
      basicAuth = { "stel" = "dontlookatmydrafts!!!"; };
      locations."/".root = "/www/dev-blog-preview";
    };
    "functionalnews.stel.codes" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:38628";
    };
  };

  services.postgresql.ensureDatabases = [ "test" "dev_blog" "functional_news" ];
  services.postgresql.ensureUsers = [
    {
      name = "functional_news_app";
      ensurePermissions = { "DATABASE functional_news" = "ALL PRIVILEGES"; };
    }
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

}
