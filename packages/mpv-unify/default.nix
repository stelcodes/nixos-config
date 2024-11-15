{ writers }:
writers.writePython3Bin "mpv-unify"
{
  libraries = [ ];
  # doCheck = true; # This will get released in 24.11
  # flake8 error codes: https://flake8.pycqa.org/en/latest/user/error-codes.html
  flakeIgnore = [
    "E501" # line length
  ];
}
  (builtins.readFile ./mpv-unify.py)

# See https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/writers/scripts.nix#L1038
