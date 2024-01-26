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
}:

let
  version = "1.9.6.1";
  src = fetchurl {
    url = "https://github.com/raduprv/Eternal-Lands/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-SAD2dJ7C76vuz8BqJK1NSpaZjP6dka2cQRdGACew+8E=";
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
    maintainers = with lib.maintainers; [ ]; #todo: add myself
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

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  configurePhase = ''
    sed -i "s|/usr/games/|$out/bin/|" pkgfiles/${pname}
    sed -i "s|/usr/share/games/EternalLands/|$out/games/${pname}/|" pkgfiles/${pname}
    sed -i "s|#data_dir = /usr/share/games/EternalLands|#data_dir = $out/games/${pname}|" pkgfiles/${pname}
    sed -i "s|#data_dir = \\\/usr\\\/share\\\/games\\\/EternalLands|#data_dir = \\\$out\\\/games\\\/${pname}|" pkgfiles/${pname}
    sed -i "s|/bin/el.linux.bin|$out/games/el.linux.bin|" pkgfiles/${pname}
    cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=. -D LOCAL_NLOHMANN_JSON=On
  '';

  buildPhase = ''
    make -j $NIX_BUILD_CORES
    make install
  '';

  installPhase = ''
    install -D -m755 pkgfiles/${pname} "$out/bin/${pname}"
    install -D -m644 pkgfiles/${pname}.6 "$out/share/man/man6/${pname}.6"
    install -D -m755 el.linux.bin "$out/games/${pname}/el.linux.bin"
    install -D -m644 pkgfiles/el.linux.bin.6 "$out/share/man/man6/el.linux.bin.6"
    install -D -m644 pkgfiles/${pname}.png "$out/share/pixmaps/${pname}.png"
    install -D -m644 pkgfiles/${pname}.xpm "$out/share/pixmaps/${pname}.xpm"
    install -D -m644 pkgfiles/${pname}.desktop "$out/share/applications/${pname}.desktop"
    install -D -m644 eternal_lands_license.txt "$out/share/licenses/${pname}/eternal_lands_license.txt"
  '';
}