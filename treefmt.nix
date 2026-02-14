{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.shfmt = {
    enable = true;
    indent_size = 4;
  };
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

  # tombi with --offline for nix sandbox compatibility
  settings.formatter.tombi = {
    command = "${pkgs.tombi}/bin/tombi";
    options = [
      "format"
      "--offline"
    ];
    includes = [ "*.toml" ];
  };
}
