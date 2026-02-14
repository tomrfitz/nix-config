{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.shfmt.enable = true;
  programs.just.enable = true;
  programs.prettier = {
    enable = true;
    includes = [
      "*.json"
      "*.md"
      "*.yaml"
      "*.yml"
    ];
  };

  # tombi: schema-aware TOML formatter (successor to taplo)
  settings.formatter.tombi = {
    command = "${pkgs.tombi}/bin/tombi";
    options = [ "format" ];
    includes = [ "*.toml" ];
  };
}
