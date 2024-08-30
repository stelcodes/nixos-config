rec {
  adminKeys = {
    yuffie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGl9G7SYvJy8+u2AF+Mlez6bwhrNfKclWo9mK6mwtNgJ";
    terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkPXakQYSkH4hp9Zmm1ewMYusc8RlUaQQnQsx2wHPpn";
    aerith = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5n9utlRl7eF5lY4CrcsOmg19KtauYjlIooR73Ir7AW";
    marlene = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIUIrkV61xmxSAGQLMatmK0hzPvp+Iekq74pW/Weep9a";
  };
  systemKeys = {
    terra = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnPEH3EdHpXZxp4yfD2/psm1m8dbHSGnQ95NLPf6S5g";
    yuffie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPv1nZsr+fdrSgtCOrYfsR0c+a3iOdaPJQHEWpZ44xXJ";
    aerith = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHq8GNrmE18CJia7L0vZdTFEBEk2+XSzGp44wQYvH/TG";
    beatrix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAd1Y+/qoZkxGvK+2qcXHzyFqOhkSFyc5cuZi8OUNqVk";
  };
  allAdminKeys = builtins.attrValues adminKeys;
  allSystemKeys = builtins.attrValues systemKeys;
  allKeys = allAdminKeys ++ allSystemKeys;
}
