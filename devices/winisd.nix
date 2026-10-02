{ stdenv
, lib
, mkWindowsApp
, wine
, fetchurl
, makeDesktopItem
, copyDesktopItems
}:
mkWindowsApp rec {
  inherit wine ;

  pname = "winisd";
  version = "0.7x";
  wineArch = "win32";
  dontUnpack = true;
  nativeBuildInputs = [ copyDesktopItems ];

  src = fetchurl {
    url = "http://www.linearteam.org/download/winisd-07x.exe";
    sha256 = "02yk82gzddl8rcmr4i5p3nvdcz08c6qkdmk8a1fl4j4yd4piriyk";
  };

  fileMap = { "$HOME/.local/share/winisd" = "drive_c/users/$USER/AppData/Roaming/winisd"; };

  winAppRun = ''
    wine start /unix ${src} "$ARGS"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "WinISD";
    })
  ];


  meta = with lib; {
    description = "Speaker simulation utility.";
    homepage = "www.linearteam.org";
    license = licenses.unfree;
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
