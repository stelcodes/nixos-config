let
  adminKeys = {
    yuffie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl9G7SYvJy8+u2AF+Mlez6bwhrNfKclWo9mK6mwtNgJ";
    terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkPXakQYSkH4hp9Zmm1ewMYusc8RlUaQQnQsx2wHPpn";
    aerith = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5n9utlRl7eF5lY4CrcsOmg19KtauYjlIooR73Ir7AW";
  };
  systemKeys = {
    terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnPEH3EdHpXZxp4yfD2/psm1m8dbHSGnQ95NLPf6S5g";
    yuffie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPv1nZsr+fdrSgtCOrYfsR0c+a3iOdaPJQHEWpZ44xXJ";
    aerith = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq8GNrmE18CJia7L0vZdTFEBEk2+XSzGp44wQYvH/TG";
  };
  allAdminKeys = builtins.attrValues adminKeys;
  allSystemKeys = builtins.attrValues systemKeys;
  allKeys = allAdminKeys ++ allSystemKeys;
in
{
  "framework-pvpn-fast-wg-quick-config.age".publicKeys = [ systemKeys.yuffie ] ++ allAdminKeys;
  "meshify-pvpn-fast-wg-quick-config.age".publicKeys = [ systemKeys.terra ] ++ allAdminKeys;
  "meshify-pvpn-sc-wg-quick-config.age".publicKeys = [ systemKeys.terra ] ++ allAdminKeys;
  "vpn-1.age".publicKeys = allKeys;
  "admin-password.age".publicKeys = allKeys;
  "root-password.age".publicKeys = allKeys;
}
