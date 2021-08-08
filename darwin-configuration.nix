{ config, pkgs, ... }:
let me = "vanilla";
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vscode
    pkgs.alacritty
  ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  # programs.zsh.enable = true; # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Enable the nix-daemon service.
  services.nix-daemon.enable = true;

  fonts.enableFontDir = true;
  fonts.fonts = [ pkgs.hack-font ];

  # https://github.com/LnL7/nix-darwin/issues/139
  system.activationScripts.applications.text = pkgs.lib.mkForce (
    ''
      echo "setting up ~/Applications/Nix..."

      rm -rf ~/Applications/Nix && mkdir -p ~/Applications/Nix
      chown ${me} ~/Applications/Nix

      IFS='
      '

      for app in $(find ${config.system.build.applications}/Applications -maxdepth 1 -type l); do
        src="$(/usr/bin/stat -f%Y "$app")" && appname="$(basename $src)"
        osascript -e "tell app \"Finder\" to make alias file at POSIX file \"/Users/${me}/Applications/Nix/\" to POSIX file \"$src\" with properties {name: \"$appname\"}";
      done
    ''
  );

  # https://github.com/NixOS/nix/issues/1669
  # https://stackoverflow.com/a/26477515/166289
  environment.launchDaemons."3_proxy_variables" = {
    enable = true;
    target = "3_proxy_variables.plist";
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>environment</string>
          <key>ProgramArguments</key>
          <array>
            <string>sh</string>
            <string>-c</string>
            <string>launchctl setenv https_proxy http://127.0.0.1:7890</string>
            <string>launchctl setenv http_proxy http://127.0.0.1:7890</string>
            <string>launchctl setenv all_proxy socks5://127.0.0.1:7890</string>
            <!-- Reload nix-daemon after set proxy environment variable. -->
            <string>launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist</string>
            <string>launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist</string>
          </array>
          <key>KeepAlive</key>
          <false/>
          <key>RunAtLoad</key>
          <true/>
          <key>WatchPaths</key>
          <array>
            <string>/etc/environment</string>
          </array>
        </dict>
      </plist>
    '';
  };

  # https://nixos.wiki/wiki/Flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Package ‘vscode’ has an unfree license (‘unfree’), refusing to evaluate.
  nixpkgs.config.allowUnfree = true;
}
