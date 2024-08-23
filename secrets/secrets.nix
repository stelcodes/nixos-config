let
  keys = (import ./keys.nix);
in
{
  "framework-pvpn-fast-wg-quick-config.age".publicKeys = [ keys.systemKeys.yuffie ] ++ keys.allAdminKeys;
  "meshify-pvpn-fast-wg-quick-config.age".publicKeys = [ keys.systemKeys.terra ] ++ keys.allAdminKeys;
  "meshify-pvpn-sc-wg-quick-config.age".publicKeys = [ keys.systemKeys.terra ] ++ keys.allAdminKeys;
  "vpn-1.age".publicKeys = keys.allKeys;
  "admin-password.age".publicKeys = keys.allKeys;
  "root-password.age".publicKeys = keys.allKeys;
}
