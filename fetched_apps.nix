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
        url = builtins.replaceStrings [ "{0}" "{1}" "{2}" ] [ name version location ] holderLink;
        sha256 = sha256;

        # https://discourse.nixos.org/t/how-to-change-the-user-agent-used-by-fetchurl/4987/2
        # https://github.com/Homebrew/homebrew-cask/blob/master/Casks/neteasemusic.rb
        curlOpts = "-A :fake";
      };

      nativeBuildInputs = [ pkgs.xar pkgs.cpio pkgs.p7zip ];
      # https://stackoverflow.com/questions/11298855/how-to-unpack-and-pack-pkg-file
      unpackPhase =
        if fileType == "dmg" then ''
          echo y | /usr/bin/hdiutil attach ${src}
          cd "/Volumes/${location}"
        '' else if fileType == "pkg" then ''
          xar -xf ${src} && cd ${location}
          cat Payload | gunzip -dc | cpio -i
        '' else if fileType == "zip" then "7z x ${src}"
        else abort "No implement compress format: ${fileType}";

      configurePhase = "echo";
      installPhase = ''
        mkdir -p $out/Applications/
        ls | grep ".app$" | head -n 1 | xargs -I {} cp -r {} $out/Applications/
      '';
    };

  txBaseUrl = "https://dldir1.qq.com";
  buildGhUrl = repo: dl: "https://github.com" + repo + "releases/download/" + dl;
  # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/editors/jetbrains/default.nix
  jbBaseUrl = "https://download.jetbrains.com";
in
[
  # Folder: Social
  (buildDarwinApps "tdesktop" "2.9.3" "Telegram Desktop"
    "https://updates.{0}.com/tmac/tsetup.{1}.dmg"
    "sha256-/jlJEVMl/LI9Hjq2b8m+raK0+occ6XlvK7xKmfFjYds=")
  (buildDarwinApps "qq-beta" "8.4.10.118" "QQ"
    "${txBaseUrl}/qqfile/{2}forMac/{2}Catalyst/{2}_{1}.dmg"
    "sha256-3tdEZD241ZEsuW2JIyeGpV62wI1+AZjHSVxyeNKBfRY=")
] ++ [
  # Folder: IDE
  (buildDarwinApps "jetbrains.appcode" "2021.1.3" "AppCode"
    "${jbBaseUrl}/objc/{2}-{1}.dmg"
    "sha256-t8LlJWEosUkRsEcvdNcnDZ4bx/9Wl9KM34Mz7Hx4ENY=")
  (buildDarwinApps "jetbrains.clion" "2021.2" "CLion"
    "${jbBaseUrl}/cpp/{2}-{1}.dmg"
    "sha256-umX/qNXJpC9w0wb2d/7BU+H2UQ107exuJkg/aUYKRX0=")
  (buildDarwinApps "idea-ultimate" "2021.2" "IntelliJ IDEA"
    "https://download.jetbrains.com/idea/ideaIU-{1}.dmg"
    "sha256-wj7p9oq71QPlAZx0XMW/KjCPgejCu9IQzPr7wRJMHlk=")
  (buildDarwinApps "webstorm" "2021.2" "WebStorm"
    "https://download.jetbrains.com/{0}/{2}-{1}.dmg"
    "sha256-edAnWOl971vHt2IdCbLTRwRj6ktk1pFNj5nXhAjM4qY=")
] ++ [
  # Folder: None
  (buildDarwinApps "yubikey-manager-qt" "1.2.3" "com.yubico.ykman.pkg"
    "https://developers.yubico.com/{0}/Releases/{0}-{1}-mac.pkg"
    "sha256-Y3FF0UyY7kJ7d7syx9BcaATRd1oD6EuYKql3WoRztSc=")
  (buildDarwinApps "motrix" "1.6.11" "Motrix"
    "https://github.com/agalwood/{2}/releases/download/v{1}/{2}-{1}-mac.zip"
    "sha256-7fBYB/rkZMiRRmuJVOsuDnTEOB4iQFe2gIdq8vwMXNE=")
] ++ [
  # Folder: Auto Start & Extensions
  (buildDarwinApps "scroll-reverser" "1.8.1" "ScrollReverser"
    "https://pilotmoon.com/downloads/ScrollReverser-{1}.zip"
    "sha256-9lGjjW/lhTStfY3dWqqm4XecgY/zAILZv/7zef7mKis=")
  (buildDarwinApps "one-switch" "317" "OneSwitch"
    "https://fireball.studio/api/release_manager/downloads/studio.fireball.{2}/{1}.zip"
    "sha256-9ubqannc8NpsBSoYr95J/Boh3qcGL+xIew9EHL5NgnE=")
  (buildDarwinApps "openinterminal" "2.3.3" "OpenInTerminal"
    "https://github.com/Ji4n1ng/{2}/releases/download/v{1}/{2}.app.zip"
    "sha256-VN++jSG0y0aIXtXrw0/t+Dgqz+tQBAgo1SsKC4p8iFs=")
  (buildDarwinApps "openinterminal-lite" "1.2.3" "OpenInTerminal-Lite"
    "https://github.com/Ji4n1ng/OpenInTerminal/releases/download/v{1}/{2}.app.zip"
    "sha256-ZyOfcgH+10V9KDrdOk8jMgA4/3V0c6HyI4+Yb9QTuFM=")
  (buildDarwinApps "openineditor-lite" "1.2.3" "OpenInEditor-Lite"
    "https://github.com/Ji4n1ng/OpenInTerminal/releases/download/v{1}/{2}.app.zip"
    "sha256-aPnJPBgySIXAOgPVccoRCiSi/Q/ZDZIxZdgvTbfgaZ0=")
  (import ./menubar_runcat.nix)
  (buildDarwinApps "snipaste" "2.6.6-Beta2" "Snipaste"
    "https://bitbucket.org/liule/{0}/downloads/{2}-{1}.dmg"
    "sha256-hYKwRbNAzDKNn6uao3aZ9rtzEqOMeyhHZoR4/G/q2RM=")
]

