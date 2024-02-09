{ appstream-glib
, cmake
, copyDesktopItems
, fetchFromGitHub
, lib
, libGLU
, makeDesktopItem
, stdenv
, SDL2_mixer
, SDL2
}:

stdenv.mkDerivation rec {
  pname = "abuse";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "Xenoveritas";
    repo = "abuse";
    rev = "v${version}";
    hash = "sha256-eneu0HxEoM//Ju2XMHnDMZ/igeVMPSLg7IaxR2cnJrk=";
  };

  desktopItems = [
    (makeDesktopItem {
      name = "abuse";
      exec = "abuse";
      icon = "abuse";
      desktopName = "Abuse";
      comment = "Side-scroller action game that pits you against ruthless alien killers";
      categories = [ "Game" "ActionGame" ];
    })
  ];

  postInstall = ''
    mv $out/bin/abuse $out/bin/.abuse-bin
    substituteAll "${./abuse.sh}" $out/bin/abuse
    chmod +x $out/bin/abuse

    install -Dm644 doc/abuse.png $out/share/pixmaps/abuse.png
  '';

  buildInputs = [ SDL2  appstream-glib libGLU ];

  nativeBuildInputs = [ SDL2_mixer cmake copyDesktopItems ];


  meta = with lib; {
    description = "Side-scroller action game that pits you against ruthless alien killers";
    homepage = "http://abuse.zoy.org/";
    license = with licenses; [ unfree ];
    # Most of abuse is free (public domain, GPL2+, WTFPL), however the creator
    # of its sfx and music only gave Debian permission to redistribute the
    # files. Our friends from Debian thought about it some more:
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=648272
    maintainers = with maintainers; [ iblech raspher ];
    platforms = platforms.unix;
    broken = stdenv.isDarwin;
  };
}
