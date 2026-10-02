{ alsa-lib
, atk
, cairo
, cups
, curl
, dbus
, dpkg
, expat
, fetchurl
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gnome2
, gtk3
, gsettings-desktop-schemas
, libgbm
, wayland
, wayland-protocols  # may not be needed at runtime
, libxkbcommon
, mesa               # for libEGL / libGL
, pipewire           # screen sharing / WebRTC on wayland
, lib
, libX11
, libxcb
, libXScrnSaver
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, libnotify
, libpulseaudio
, libuuid
, libglvnd
, ffmpeg
, nspr
, nss
, pango
, stdenv
, systemd
, at-spi2-atk
, at-spi2-core
}:

let

  mirror = https://get.geo.opera.com/pub/opera_gx;
  version = "129.0.5823.64";

  rpath = lib.makeLibraryPath [

    # These provide shared libraries loaded when starting. If one is missing,
    # an error is shown in stderr.
    alsa-lib.out
    atk.out
    cairo.out
    cups
    curl.out
    dbus.lib
    expat.out
    fontconfig.lib
    freetype.out
    gdk-pixbuf.out
    glib.out
    gsettings-desktop-schemas.out
    gnome2.GConf
    gtk3.out
    wayland.out
    wayland-protocols.out  # may not be needed at runtime
    libxkbcommon.out
    mesa.out               # for libEGL / libGL
    pipewire.out           # screen sharing / WebRTC on wayland
    libX11.out
    libgbm.out
    libXScrnSaver.out
    libXcomposite.out
    libXcursor.out
    libXdamage.out
    libXext.out
    libXfixes.out
    libXi.out
    libXrandr.out
    libXrender.out
    libXtst.out
    libxcb.out
    libnotify.out
    libuuid.out
    nspr.out
    nss.out
    pango.out
    ffmpeg.out
    stdenv.cc.cc.lib

    # This is a little tricky. Without it the app starts then crashes. Then it
    # brings up the crash report, which also crashes. `strace -f` hints at a
    # missing libudev.so.0.
    systemd

    # Works fine without this except there is no sound.
    libpulseaudio.out

    at-spi2-atk
    at-spi2-core
  ];

in stdenv.mkDerivation {

  name = "opera-gx-${version}";

  src = fetchurl {
    url = "${mirror}/${version}/linux/opera-gx-stable_${version}_amd64.deb";
    sha256 = "f084698cb9bb99f45a6eaf4436d4357d8531659422b296dc87c7cbca40c10fa1";
  };

  unpackCmd = "${dpkg}/bin/dpkg-deb -x $curSrc .";

  installPhase = ''
    mkdir --parent $out
    mv * $out/
    cp $out/lib/*/opera-gx-stable/*.so $out/lib/
    ln -sf ${libglvnd}/lib/libEGL.so.1 $out/lib/libEGL.so.1

  '';

  postFixup = ''
    find $out -executable -type f \
    | while read f
      do
        patchelf \
          --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$out/lib:${rpath}" \
          "$f"
      done
  '';

  meta = {
    homepage = https://www.opera.com/gx;
    description = "Web browser";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.unfree;
  };
}
