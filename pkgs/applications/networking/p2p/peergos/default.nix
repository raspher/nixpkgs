{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "peergos";
  version = "0.14.1";

  peergos = fetchurl {
    url = "https://github.com/Peergos/web-ui/releases/download/v${version}/Peergos.jar";
    hash = "sha256-oCsUuFxTAL0vAabGggGhZHaF40A5TLfkT15HYPiKHlU=";
  };

  dontUnpack = 1;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/java/
    cp $peergos $out/share/java/peergos.jar

    makeWrapper ${jre}/bin/java $out/bin/peergos --chdir $out/share/peergos/ --add-flags "-Djava.library.path=$out/share/peergos/native-lib/libtweetnacl.so -jar $out/share/java/peergos.jar"
    mkdir -p $out/share/peergos/ && cd $out/share/peergos/
    ${jre}/bin/java -jar $out/share/java/peergos.jar
    '';

  meta = with lib; {
    description = "A p2p, secure file storage, social network and application protocol";
    homepage = "https://peergos.org/";
    license = licenses.agpl3Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ raspher ];
  };
}
