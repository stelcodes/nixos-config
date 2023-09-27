let
  users = {
    stel-framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl9G7SYvJy8+u2AF+Mlez6bwhrNfKclWo9mK6mwtNgJ";
  };
  systems = {
    meshify = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnPEH3EdHpXZxp4yfD2/psm1m8dbHSGnQ95NLPf6S5g";
    framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPv1nZsr+fdrSgtCOrYfsR0c+a3iOdaPJQHEWpZ44xXJ";
  };
  allSystems = builtins.attrValues systems;
  allUsers = builtins.attrValues users;
  allEntities = allSystems ++ allUsers;
in
{
  # For all systems use `builtins.attrValues systems`

  "meshify/wg/pvpn-fast/private-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-fast/public-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-fast/endpoint.age".publicKeys = [ systems.meshify ];

  "meshify/wg/pvpn-secure/private-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-secure/public-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/pvpn-secure/endpoint.age".publicKeys = [ systems.meshify ];

  "framework-pvpn-fast-wg-quick-config.age".publicKeys = [ systems.framework ];

  "admin-password.age".publicKeys = allEntities;
  "root-password.age".publicKeys = allEntities;
}
