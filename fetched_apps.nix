let
  pkgs = import <nixpkgs> { };
  buildDarwinApps = name: version: link: sha256: extraComamnd: pkgs.stdenv.mkDerivation rec {
    inherit name version;
    isZip = if pkgs.lib.hasSuffix link ".zip" then true else false;

    src = pkgs.fetchurl {
      url = link;
      sha256 = sha256;
    };

    nativeBuildInputs = [ pkgs.unzip pkgs.p7zip ];
    unpackPhase = if isZip then "unzip ${src}" else "7z x ${src} || true";
    installPhase = ''
      mkdir -p $out/Applications/
      # https://stackoverflow.com/questions/46021955/get-first-line-of-a-shell-commands-output
      # https://stackoverflow.com/questions/1610089/how-to-use-cp-from-stdin
      find . | grep "\.app" | head -n 1 | xargs -I {} cp -r {} $out/Applications/ || true
    '' + "cd $out;" + extraComamnd;
  };
in
[
  # (mac_zip_apps "atom" "1.58.0"
  #   "https://github.com/atom/atom/releases/download/v1.58.0/atom-mac.zip"
  #   "sha256-KNjPSH5oJx3ofgQn2LVmYJ4p1Avp/wp2wJ7HKIOo6DY=")

  (buildDarwinApps "idea-ultimate" "2021.2"
    "https://download.jetbrains.com/idea/ideaIU-2021.2.dmg"
    "sha256-wj7p9oq71QPlAZx0XMW/KjCPgejCu9IQzPr7wRJMHlk="
    "chmod +x './Applications/IntelliJ IDEA.app/Contents/MacOS/idea'")
]
