{ stdenv
, lib
, fetchFromGitHub
, makeWrapper
, coreutils
, libnotify
}:

stdenv.mkDerivation rec {
  pname = "pomo-sh";
  version = "unstable-2023-01-26";

  src = fetchFromGitHub {
    owner = "stelcodes";
    repo = "pomo";
    rev = "1fa2468c45db6711b72e775fe324c5a9c1d13a05";
    sha256 = "O6YBfXwfcMd2niNd0laPt060ub5j/hqcMft4KWKaYTk=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 pomo.sh $out/bin/pomo

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/pomo --prefix PATH : ${lib.makeBinPath [ coreutils libnotify ]}
  '';

  meta = with lib; {
    description = "A simple Pomodoro timer written in Bash ";
    homepage = "https://github.com/jsspencer/pomo";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
  };
}
