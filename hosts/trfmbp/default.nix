{
  pkgs,
  agenix,
  user,
  ...
}:
{
  imports = [
    ../../modules/shared/system/nix.nix
    ../../modules/shared/system/stylix.nix
    ../../modules/darwin/system
  ];

  system.stateVersion = 5;
  system.primaryUser = user;

  networking.hostName = "trfmbp";
  networking.localHostName = "trfmbp";
  networking.computerName = "trfmbp";

  users.users.${user} = {
    name = user;
    home = "/Users/${user}";
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    nix
    agenix.packages.aarch64-darwin.default
  ];
}
