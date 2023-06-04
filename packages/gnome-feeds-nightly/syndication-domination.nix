{ stdenv
, fetchFromGitLab
, pkg-config
, meson
, ninja
, python3
, pugixml
, html-tidy
, fmt
}:

stdenv.mkDerivation rec {
  pname = "syndication-domination";
  version = "75920321062d682437f3fb0319dad227d8b18f6c";
  src = fetchFromGitLab {
    owner = "GabMus";
    repo = pname;
    rev = version;
    sha256 = "sha256-fOlE9CsNcmGkVBXaqYHxLDWB8voeRp46+dZYIJIwg7o=";
  };
  nativeBuildInputs = [ pkg-config meson ninja (python3.withPackages (p: [ p.pybind11 ])) ];
  buildInputs = [
    pugixml
    html-tidy
    fmt
  ];
  mesonFlags = [
    "-DTO_JSON_BINARY=true"
    "-DPYTHON_BINDINGS=true"
    "-DHTML_SUPPORT=true"
  ];
}
