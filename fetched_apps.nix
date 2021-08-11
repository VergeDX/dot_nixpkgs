let
  pkgs = import <nixpkgs> { };
  mac_zip_apps = name: version: link: sha256: pkgs.stdenv.mkDerivation rec {
    inherit name version;

    src = pkgs.fetchurl {
      url = link;
      sha256 = sha256;
    };

    nativeBuildInputs = [ pkgs.unzip ];
    unpackPhase = "unzip ${src}";
    installPhase = ''
      mkdir -p $out/Applications
      cp -r * $out/Applications
      rm $out/Applications/env-vars
    '';
  };
in
[
  # (mac_zip_apps "atom" "1.58.0"
  #   "https://github.com/atom/atom/releases/download/v1.58.0/atom-mac.zip"
  #   "sha256-KNjPSH5oJx3ofgQn2LVmYJ4p1Avp/wp2wJ7HKIOo6DY=")
]
