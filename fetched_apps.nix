let
  pkgs = import <nixpkgs> { };
  # https://kotlinlang.org/api/latest/jvm/stdlib/kotlin.text/take-last.html
  stringTakeLast =
    str: last:
    let strLen = pkgs.lib.stringLength str;
    in pkgs.lib.substring (strLen - last) strLen str;

  buildDarwinApps = name: version: location: holderLink: sha256:
    let supportFmt = [ "dmg" "pkg" "zip" ]; in
    pkgs.stdenv.mkDerivation rec {
      inherit name version;

      fileType = let extName = stringTakeLast holderLink 3; in
        if builtins.elem extName supportFmt then extName
        else abort "Unsupported compression file types: ${extName}";

      src = pkgs.fetchurl {
        url = builtins.replaceStrings [ "{}" ] [ version ] holderLink;
        sha256 = sha256;

        # https://discourse.nixos.org/t/how-to-change-the-user-agent-used-by-fetchurl/4987/2
        # https://github.com/Homebrew/homebrew-cask/blob/master/Casks/neteasemusic.rb
        curlOpts = "-A :fake";
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

      configurePhase = "echo";
      installPhase = ''
        mkdir -p $out/Applications/
        ls | grep ".app$" | head -n 1 | xargs -I {} cp -r {} $out/Applications/
      '';
    };

  # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/editors/jetbrains/default.nix
  jbBaseUrl = "https://download.jetbrains.com";
in
[
  (buildDarwinApps "jetbrains.appcode" "2021.1.3" "AppCode"
    "${jbBaseUrl}/objc/AppCode-{}.dmg"
    "sha256-t8LlJWEosUkRsEcvdNcnDZ4bx/9Wl9KM34Mz7Hx4ENY=")
  (buildDarwinApps "jetbrains.clion" "2021.2" "CLion"
    "${jbBaseUrl}/cpp/CLion-{}.dmg"
    "sha256-umX/qNXJpC9w0wb2d/7BU+H2UQ107exuJkg/aUYKRX0=")
  (buildDarwinApps "idea-ultimate" "2021.2" "IntelliJ IDEA"
    "https://download.jetbrains.com/idea/ideaIU-{}.dmg"
    "sha256-wj7p9oq71QPlAZx0XMW/KjCPgejCu9IQzPr7wRJMHlk=")
  (buildDarwinApps "webstorm" "2021.2" "WebStorm"
    "https://download.jetbrains.com/webstorm/WebStorm-{}.dmg"
    "sha256-edAnWOl971vHt2IdCbLTRwRj6ktk1pFNj5nXhAjM4qY=")
] ++ [
  (buildDarwinApps "neteasemusic" "2.3.5_856" "网易云音乐"
    "https://d1.music.126.net/dmusic/NeteaseMusic_{}_web.dmg"
    "sha256-zkcGKvm5rL9AexzYuxo/eYsodys46yuR3dByYLvhNqw=")
] ++ [
  # (buildDarwinApps "atom" "1.58.0" "Atom"
  #   "https://github.com/atom/atom/releases/download/v1.58.0/atom-mac.zip"
  #   "sha256-KNjPSH5oJx3ofgQn2LVmYJ4p1Avp/wp2wJ7HKIOo6DY=")

  # (buildDarwinApps "zoom-us" "5.7.4.898" "zoomus.pkg"
  # "https://zoom.us/client/5.7.4.898/Zoom.pkg"
  # "sha256-RLk3uw2bhQIov94qvncpaZFSjW3aSdf/ZRKlIirQIuY=")
]
