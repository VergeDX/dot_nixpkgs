let
  pkgs = import <nixpkgs> { };
  # https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.text/take-last.html
  stringTakeLast =
    str: last:
    let strLen = pkgs.lib.stringLength str;
    in pkgs.lib.substring (strLen - last) strLen str;

  buildDarwinApps = name: version: location: link: sha256:
    let supportFmt = [ "dmg" "pkg" "zip" ]; in
    pkgs.stdenv.mkDerivation rec {
      inherit name version;

      fileType = let extName = stringTakeLast link 3; in
        if builtins.elem extName supportFmt then extName
        else abort "Unsupported compression file types: ${extName}";

      src = pkgs.fetchurl {
        url = link;
        sha256 = sha256;
      };

      nativeBuildInputs = [ pkgs.xar pkgs.cpio pkgs.unzip ];
      # https://stackoverflow.com/questions/11298855/how-to-unpack-and-pack-pkg-file
      unpackPhase =
        if fileType == "dmg" then ''
          /usr/bin/hdiutil attach ${src}
          cd "/Volumes/${location}"
        '' else if fileType == "pkg" then ''
          xar -xf ${src} && cd ${location}
          cat Payload | gunzip -dc | cpio -i
        '' else if fileType == "zip" then "unzip ${src}"
        else abort "No implement compress format: ${fileType}";

      installPhase = ''
        mkdir -p $out/Applications/
        find . | grep ".app$" | head -n 1 | xargs -I {} cp -r {} $out/Applications/
      '';
    };
in
[
  # (buildDarwinApps "atom" "1.58.0" "Atom"
  #   "https://github.com/atom/atom/releases/download/v1.58.0/atom-mac.zip"
  #   "sha256-KNjPSH5oJx3ofgQn2LVmYJ4p1Avp/wp2wJ7HKIOo6DY=")

  # (buildDarwinApps "zoom-us" "5.7.4.898" "zoomus.pkg"
  # "https://zoom.us/client/5.7.4.898/Zoom.pkg"
  # "sha256-RLk3uw2bhQIov94qvncpaZFSjW3aSdf/ZRKlIirQIuY=")

  # (buildDarwinApps "idea-ultimate" "2021.2" "IntelliJ IDEA"
  #   "https://download.jetbrains.com/idea/ideaIU-2021.2.dmg"
  #   "sha256-wj7p9oq71QPlAZx0XMW/KjCPgejCu9IQzPr7wRJMHlk=")
]
