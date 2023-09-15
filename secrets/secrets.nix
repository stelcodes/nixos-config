let
  users = { };
  systems = {
    meshify = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnPEH3EdHpXZxp4yfD2/psm1m8dbHSGnQ95NLPf6S5g";
  };
in
{
  # For all systems use `builtins.attrValues systems`

  "meshify/wg/protonvpn-fast/private-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/protonvpn-fast/public-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/protonvpn-fast/endpoint.age".publicKeys = [ systems.meshify ];

  "meshify/wg/protonvpn-secure/private-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/protonvpn-secure/public-key.age".publicKeys = [ systems.meshify ];
  "meshify/wg/protonvpn-secure/endpoint.age".publicKeys = [ systems.meshify ];
}
