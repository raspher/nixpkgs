{ lib
, stdenv
, fetchFromGitHub
, cmake
, cpm-cmake
, qt6
, pkg-config
, simdutf
}:

stdenv.mkDerivation rec {
  pname = "klogg";
  version = "22.06";

  src = fetchFromGitHub {
    owner = "variar";
    repo = "klogg";
    rev = "v${version}";
    hash = "sha256-RXISwpQKY9ZLoIGIEpvsXfWIIvtn98mXror39Ko/OZs=";
  };

  propagatedBuildInputs = [
    simdutf
  ];

  buildInputs = with qt6; [
    qttools
    wrapQtAppsHook
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  meta = with lib; {
    description = "Really fast log explorer based on glogg project";
    homepage = "https://github.com/variar/klogg";
    changelog = "https://github.com/variar/klogg/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "klogg";
    platforms = platforms.all;
  };
}
