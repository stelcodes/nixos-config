{ pkgs, config, ... }: {
  config = {

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_13;
      enableTCPIP = false;
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
      ensureUsers = [{
        name = "stel";
        # ALTER USER stel WITH SUPERUSER;
        # To change password:
        # ALTER USER <user> WITH PASSWORD '<password>';
      }];
    };

  };
}
