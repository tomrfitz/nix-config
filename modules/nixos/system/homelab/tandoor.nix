# Tandoor Recipes — recipe management, meal planning, shopping lists.
# Uses NixOS-native module with local PostgreSQL (Unix socket).
# Port 8099 (SABnzbd uses default 8080); open data plugin configured in app UI after first launch.
# https://github.com/TandoorRecipes/recipes
# https://github.com/TandoorRecipes/open-tandoor-data
{
  config,
  lib,
  ...
}:
let
  cfg = config.trf.homelab;
in
{
  config = lib.mkIf (cfg.enable && config.services.tandoor-recipes.enable) {
    sops.secrets."tandoor/secret-key" = {
      owner = "tandoor_recipes";
      restartUnits = [ "tandoor-recipes.service" ];
    };

    # sops-nix decrypts to a file containing just the value;
    # Tandoor needs SECRET_KEY as an env var, so use an EnvironmentFile
    # with KEY=value format via sops.templates.
    sops.templates."tandoor-env" = {
      owner = "tandoor_recipes";
      content = ''
        SECRET_KEY=${config.sops.placeholder."tandoor/secret-key"}
      '';
    };

    services.tandoor-recipes = {
      address = "0.0.0.0";
      port = 8099; # SABnzbd uses default 8080
      database.createLocally = true;
    };

    systemd.services.tandoor-recipes.serviceConfig.EnvironmentFile =
      config.sops.templates."tandoor-env".path;

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ 8099 ];
  };
}
