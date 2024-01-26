{ fmt, stdenv, newScope }:
let
  callPackage = newScope self;

  self = {
    cal3d = callPackage ./cal3d.nix { inherit stdenv; };

    el-unwrapped = callPackage ./el.nix { inherit stdenv; };

    el-data = callPackage ./el-data.nix { inherit stdenv; };

    el = callPackage ./wrapper.nix { };
  };

in
self