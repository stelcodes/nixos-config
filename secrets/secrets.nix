let
  adminKeys = {
    framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl9G7SYvJy8+u2AF+Mlez6bwhrNfKclWo9mK6mwtNgJ";
    meshify = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkPXakQYSkH4hp9Zmm1ewMYusc8RlUaQQnQsx2wHPpn";
  };
  systemKeys = {
    meshify = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnPEH3EdHpXZxp4yfD2/psm1m8dbHSGnQ95NLPf6S5g";
    framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPv1nZsr+fdrSgtCOrYfsR0c+a3iOdaPJQHEWpZ44xXJ";
  };
  allAdminKeys = builtins.attrValues adminKeys;
  allSystemKeys = builtins.attrValues systemKeys;
  allKeys = allAdminKeys ++ allSystemKeys;
in
{
  "framework-pvpn-fast-wg-quick-config.age".publicKeys = [ systemKeys.framework ] ++ allAdminKeys;
  "meshify-pvpn-fast-wg-quick-config.age".publicKeys = [ systemKeys.meshify ] ++ allAdminKeys;
  "admin-password.age".publicKeys = allKeys;
  "root-password.age".publicKeys = allKeys;
}
