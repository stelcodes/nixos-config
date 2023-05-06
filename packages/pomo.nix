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
    owner = "jsspencer";
    repo = "pomo";
    rev = "47e57fe2c75677bd7a1491f93510e830a8008cac";
    sha256 = "eGLjvfKeTgSuC7sCk7qN5K73tr5vbJHuD0v7cIg5ZpA=";
  };

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ coreutils ];

  postPatch = ''
    patchShebangs pomo.sh
  '';

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
