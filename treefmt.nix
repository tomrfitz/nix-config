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
      "*.yaml"
      "*.yml"
    ];
  };

  settings.formatter.markdownlint = {
    command = "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2";
    options = [ "--fix" ];
    includes = [ "*.md" ];
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
