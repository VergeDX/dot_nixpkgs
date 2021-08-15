let
  pkgs = import <nixpkgs> { };
  app_name = "ClashX";
  clashX = pkgs.stdenv.mkDerivation rec {
    name = "clashX";
    version = "1.65.1";

    src = pkgs.fetchurl {
      url = "https://github.com/yichengchen/${name}/releases/download/${version}/${app_name}.dmg";
      sha256 = "sha256-yb/7lzqSbKS3WywZgl/0dPT9f3gD9kgGbbViiboPKPs=";
    };

    unpackPhase = ''
      /usr/bin/hdiutil attach ${src}
      cd /Volumes/${app_name}/
    '';
    installPhase = ''
      mkdir -p $out/Applications/
      cp -r ${app_name}.app $out/Applications/
    '';
  };
in
clashX
