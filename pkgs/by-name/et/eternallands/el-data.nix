{ el-unwrapped
, dos2unix
, fetchzip
, lib
, stdenv
}:

let
  version = "1.9.6.1";
in
stdenv.mkDerivation rec {
  inherit (el-unwrapped) version;
  pname = "eternallands-data";
  src = fetchzip {
      url = "https://github.com/raduprv/Eternal-Lands/releases/download/${version}/eternallands-data_${version}.zip";
      hash = "sha256-ovSmrdUzUqvEUYLwefg+YJsrP/VF5WSzlf47gHcef+k=";
    };
  meta = {
    homepage = "http://www.eternal-lands.com";
    description = "A free 3D MMORPG game with thousands of on-line players";
    license = lib.licenses.free;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ]; #todo: add myself
  };
  buildInputs = [ dos2unix ];
  installPhase = ''
    find ./* -type f -exec install -Dm644 "{}" "$out/games/eternallands/data/{}" \;
    dos2unix $out/games/eternallands/data/license.txt
  '';
}