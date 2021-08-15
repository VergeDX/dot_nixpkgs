{ config, pkgs, ... }:
let me = "vanilla";
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    (import ./clashX.nix)
    pkgs.vscode
    pkgs.iterm2
  ] ++ import ./fetched_apps.nix;

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # https://nixos.wiki/wiki/Flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Enable the nix-daemon service.
  services.nix-daemon.enable = true;

  fonts.enableFontDir = true;
  fonts.fonts = [
    pkgs.nerdfonts
    pkgs.powerline-fonts
    pkgs.powerline-symbols
  ] ++ [ pkgs.wineWowPackages.fonts ];

  # Package ‘vscode’ has an unfree license (‘unfree’), refusing to evaluate.
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./3_proxy_variables.nix
    ./applications_fix.nix
  ];
}
