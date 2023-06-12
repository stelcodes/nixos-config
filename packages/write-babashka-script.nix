{ writeTextFile
, babashka
, lib
, runtimeShell
}:
{ name
, text ? null
, source ? null
, runtimeInputs ? [ ]
, checkPhase ? null
}:
assert (builtins.typeOf text == "string") || (builtins.typeOf source == "path");
let sourceFile = writeTextFile {
  inherit name;
  text = ''
    ${if (text != null) then text else builtins.readFile source}
  '';
  # destination = "${name}.clj";
}; in
writeTextFile {
  name = ".${name}-wrapped";
  executable = true;
  destination = "/bin/${name}";
  text = ''
    #!${runtimeShell}
    set -o errexit
    set -o nounset
    set -o pipefail
  '' + lib.optionalString (runtimeInputs != [ ]) ''

    export PATH="${lib.makeBinPath runtimeInputs}:$PATH"
  '' + ''

    ${babashka}/bin/bb ${sourceFile}
  '';
}
