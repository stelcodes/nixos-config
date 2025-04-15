let
  keys = (import ./keys.nix);
in
{
  "admin-password.age".publicKeys = keys.allKeys;
  "root-password.age".publicKeys = keys.allKeys;
}
