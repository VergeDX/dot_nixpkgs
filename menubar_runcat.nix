let
  pkgs = import <nixpkgs> { };
  menubar_runcat = pkgs.stdenv.mkDerivation rec {
    name = "menubar_runcat";
    version = "86a5406";

    src = pkgs.fetchgit {
      url = "https://github.com/VergeDX/menubar_runcat.git";
      rev = "${version}63943dd6df347063b4b36510c4303d294";
      sha256 = "sha256-PKe58qUJts66HrTAbQD8hj6Tv73Fu1asfLmGELizxz4=";
    };

    # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/terminal-emulators/iterm2/default.nix
    preConfigure = "LD=$CC";
    # https://github.com/gnachman/iTerm2/blob/master/Makefile
    buildPhase = "/usr/bin/xcodebuild -scheme \"Menubar RunCat\" -derivedDataPath .";
    installPhase = ''
      mkdir -p $out/Applications/
      find . | grep "\.app$" | xargs -I {} cp -r {} $out/Applications/
    '';
  };
in
menubar_runcat
