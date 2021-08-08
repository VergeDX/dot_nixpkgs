{ pkgs, ... }:
let
  vergedx_fonts_baseurl = "https://github.com/VergeDX/config-nixpkgs/raw/master/packages/fonts";
  call_fonts = file_name: (pkgs.callPackage
    (builtins.fetchurl "${vergedx_fonts_baseurl}/${file_name}")
    { });
in
[
  # https://github.com/VergeDX/config-nixpkgs/tree/master/packages/fonts
  (call_fonts "new-york.nix")
  (call_fonts "sf-arabic-beta.nix")
  (call_fonts "sf-compact.nix")
  (call_fonts "sf-mono.nix")
  (call_fonts "sf-pro.nix")
]
