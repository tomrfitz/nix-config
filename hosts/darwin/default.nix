{ config, pkgs, ... }:

let
  user = "tomrfitz";
in
{
  system.stateVersion = 5;
  system.primaryUser = user;

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    casks = [
      "ghostty"
      "zed"
      "visual-studio-code"
      "slack"
      "discord"
      "firefox"
      "google-chrome"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [ nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
