{ stdenv, lib, fetchFromGitHub, fetchurl, unzip, autoPatchelfHook, leiningen
, graalvm11-ce, glibcLocales }:

with lib;
stdenv.mkDerivation rec {
  pname = "jet";
  version = "0.0.15";

  # nix-prefetch-github-latest-release --nix borkdude jet
  # src = fetchFromGitHub {
  #   owner = "borkdude";
  #   repo = "jet";
  #   rev = "a67833394c56bc4ce4929ba5d5370da1c5c966b4";
  #   sha256 = "0dgkxiga6wagxdj72k32l2idd03g40c25ks32fjvisalgl4v3jwd";
  #   fetchSubmodules = false;
  # };

  src = fetchurl {
    url =
      "https://github.com/borkdude/${pname}/releases/download/${version}/${pname}-filter-${version}";
    sha256 = "1wh8jyj7alfa6h0cycfwffki83wqb5d5x0p7kvgdkhl7jx7isrwj";
  };

  # nativeBuildInputs = [ leiningen graalvm11-ce glibcLocales ];
  nativeBuildInputs = [ unzip autoPatchelfHook ];

  # https://github.com/borkdude/jet/blob/master/script/compile
  buildPhase = ''
    HOME=$NIX_BUILD_TOP

    lein with-profiles +clojure-1.10.3 do clean, uberjar

    native-image \
      -jar target/jet-${version}-standalone.jar \
      -H:Name=${pname} \
      -H:+ReportExceptionStackTraces \
      -J-Dclojure.spec.skip-macros=true \
      -J-Dclojure.compiler.direct-linking=true \
      "-H:IncludeResources=JET_VERSION" \
      -H:ReflectionConfigurationFiles=reflection.json \
      --initialize-at-build-time  \
      -H:Log=registerResource: \
      --verbose \
      --no-fallback \
      --no-server \
      "-J-Xmx3g"

    lein clean
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${pname} $out/bin/${pname}
  '';

  meta = {
    description =
      "CLI to transform between JSON, EDN and Transit, powered with a minimal query language.";
    longDescription = ''
      This is a command line tool to transform between JSON, EDN and Transit,
      powered with a minimal query language. It runs as a GraalVM binary with
      fast startup time which makes it suited for shell scripting. It comes
      with a query language to do intermediate transformation. It may seem 
      familiar to users of jq. Although in 2021, you may just want to use the
      --func option instead (who needs a DSL if you can use normal Clojure?)
    '';
    homepage = "https://github.com/borkdude/jet";
    license = licenses.epl10;
    platforms = graalvm11-ce.meta.platforms;
    maintainers = with maintainers; [ stelcodes ];
  };

}
