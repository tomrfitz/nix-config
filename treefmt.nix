{ pkgs, lib, ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.shfmt = {
    enable = true;
    indent_size = 4;
  };
  programs.just.enable = true;
  programs.statix.enable = true;

  # dprint formats md/json/yaml/toml and (importantly) code blocks embedded in
  # markdown via the same plugins. Plugins come from nixpkgs so this stays
  # sandbox-safe (no plugin URL fetches at format/eval time).
  # Plugin docs: https://dprint.dev/plugins/
  programs.dprint = {
    enable = true;
    settings = {
      lineWidth = 100;
      indentWidth = 2;
      plugins = pkgs.dprint-plugins.getPluginList (
        plugins: with plugins; [
          dprint-plugin-markdown
          dprint-plugin-json
          dprint-plugin-toml
          g-plane-pretty_yaml
        ]
      );
      markdown = {
        textWrap = "maintain";
        unorderedListKind = "dashes";
        emphasisKind = "underscores";
      };
      excludes = [
        "flake.lock"
        "secrets/*"
        ".sops.yaml"
      ];
    };
  };

  # markdownlint-cli2 stays as an advisory linter (no --fix) for rules dprint
  # doesn't enforce: MD026 (heading trailing punctuation) and MD034 (bare URLs).
  settings.formatter.markdownlint = {
    command = "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2";
    includes = [ "*.md" ];
  };
}
