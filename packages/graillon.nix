{ lib, stdenv, fetchzip, libX11, gcc, autoPatchelfHook }:
stdenv.mkDerivation rec {
  pname = "graillon";
  version = "2.7";

  src = fetchzip {
    url = "https://www.auburnsounds.com/downloads/Graillon-FREE-${version}.zip";
    hash = "sha256-ZFeiInMrX1cOuWet4z61LmV1DlZ+3WKLNY4ZEMK2IG4=";
    stripRoot = true;
    postFetch = ''
      rm -r $out/Mac $out/Windows $out/Linux/Linux-64b-LV2-FREE $out/Linux/Linux-64b-VST2-FREE
    '';
  };

  nativeBuildInputs = [ autoPatchelfHook libX11 gcc.cc.libgcc ];

  installPhase = ''
    mkdir -p $out/lib/vst3
    cp -R Linux/Linux-64b-VST3-FREE/*.vst3 $out/lib/vst3
  '';

  meta = with lib; {
    description = "Pitch shift and correction audio plug-in from Auburn Sounds";
    homepage = "https://www.auburnsounds.com/products/Graillon.html";
    license = with licenses; [ unfree ];
    platforms = platforms.linux;
  };
}
