{ lib
, fetchzip
, stdenv
, fetchurl
, cmake
, openal
, pkg-config
, SDL2
, SDL2_ttf
, SDL2_image
, SDL2_net
, libvorbis
, zlib
, libGLU
, libpng
, libxml2
, libXrandr
, openssl
, nlohmann_json
, tree
, doxygen
, fetchpatch
, gzip
, dos2unix
, cal3d
  # wrap
, makeBinaryWrapper
, pciutils
, glxinfo
}:

let
  version = "1.9.6.1";
  src = fetchurl {
    url = "https://github.com/raduprv/Eternal-Lands/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-SAD2dJ7C76vuz8BqJK1NSpaZjP6dka2cQRdGACew+8E=";
  };
  data = fetchzip {
    url = "https://github.com/raduprv/Eternal-Lands/releases/download/${version}/eternallands-data_${version}.zip";
    hash = "sha256-ovSmrdUzUqvEUYLwefg+YJsrP/VF5WSzlf47gHcef+k=";
  };
in
stdenv.mkDerivation rec {
  inherit version cal3d src;
  pname = "eternallands";
  meta = {
    homepage = "http://www.eternal-lands.com";
    description = "A free 3D MMORPG game with thousands of on-line players";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ raspher ]; #todo: add myself
  };

  buildInputs = [
    cal3d
    SDL2
    SDL2_ttf
    SDL2_image
    SDL2_net
    libvorbis
    openal
    zlib
    libGLU
    libpng
    libxml2
    libXrandr
    openssl
    nlohmann_json
    tree
  ];

  installPhase = ''
    runHook preInstall

    install -D -m755 el.linux.bin $out/share/games/eternallands/el.linux.bin
    install -D -m755 ../pkgfiles/${pname} "$out/bin/${pname}"
    install -D -m644 ../pkgfiles/${pname}.6 "$out/share/man/man6/${pname}.6"
    install -D -m644 ../pkgfiles/el.linux.bin.6 "$out/share/man/man6/el.linux.bin.6"
    install -D -m644 ../pkgfiles/${pname}.png "$out/share/pixmaps/${pname}.png"
    install -D -m644 ../pkgfiles/${pname}.xpm "$out/share/pixmaps/${pname}.xpm"
    install -D -m644 ../pkgfiles/${pname}.desktop "$out/share/applications/${pname}.desktop"
    install -D -m644 ../eternal_lands_license.txt "$out/share/licenses/${pname}/eternal_lands_license.txt"

    cp -r ${data}/* $out/share/games/eternallands/

    runHook postInstall
  '';

  postInstall = ''
    # fix eternallands wrapper script
    ls -lha
    sed -i "s|/usr/games/|$out/share/games/eternallands/|g" $out/bin/eternallands
    sed -i "s|/usr/share/games/EternalLands/|$out/share/games/eternallands/|g" $out/bin/eternallands
    sed -i "s|\\\/usr\\\/share\\\/games\\\/EternalLands/|\\\/$out\\\/share\\\/games\\\/eternallands/|g" $out/bin/eternallands
    sed -i "s|/bin/el.linux.bin|$out/share/games/eternallands/el.linux.bin|g" $out/bin/eternallands

    # fix configuration data dir
    sed -i "s|c:\\\Program Files\\\Eternal Lands\\\|$out/share/games/eternallands/|g" $out/share/games/eternallands/el.ini
  '';

  postFixup = ''
    wrapProgram $out/bin/eternallands \
      --prefix PATH : ${lib.makeBinPath [ pciutils glxinfo ]} \
      --chdir "$out/share/games/eternallands/"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeBinaryWrapper
  ];
}
