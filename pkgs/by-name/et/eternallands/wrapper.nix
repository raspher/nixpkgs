{ buildEnv, makeWrapper, el-unwrapped, el-data, tree }:

assert el-unwrapped.version == el-data.version;

buildEnv {
  name = "el-${el-unwrapped.version}";

  nativeBuildInputs = [ makeWrapper ];

  paths = [ el-unwrapped el-data ];

  pathsToLink = [ "/" "/bin" ];

  buildInputs = [ tree ];
  postBuild = ''
  tree $out/bin
    for i in $out/bin/*; do
      wrapProgram "$i" \
        --set ZEROAD_ROOTDIR "$out/share/eternallands"
    done
  '';

  meta = el-unwrapped.meta // {
    hydraPlatforms = [];
  };
}
