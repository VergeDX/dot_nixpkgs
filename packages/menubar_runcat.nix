let
  pkgs = import <nixpkgs> { };
  menubar_runcat = pkgs.stdenv.mkDerivation rec {
    name = "menubar_runcat";
    version = "3ce266a";

    src = pkgs.fetchgit {
      url = "https://github.com/VergeDX/menubar_runcat.git";
      rev = "${version}7aa1aafdec43a65e4ce45eafc12df7406";
      sha256 = "sha256-Lnl9g12aoHrSY6/FoYf73HvWyh2OyOi0zhBs3S407zo=";
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
