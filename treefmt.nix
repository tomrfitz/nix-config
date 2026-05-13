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
    # treefmt-nix's defaults (`includes = [".*"]`, `excludes = []`) are
    # treefmt-style regex but get copied verbatim into dprint.json where
    # they're read as gitignore globs (so `.*` would only match dotfiles
    # and our settings.excludes get overridden). Set both explicitly.
    includes = lib.mkForce [
      "**/*.md"
      "**/*.json"
      "**/*.jsonc"
      "**/*.toml"
      "**/*.yaml"
      "**/*.yml"
    ];
    excludes = lib.mkForce [
      "flake.lock"
      "secrets/**"
      ".sops.yaml"
      "**/package-lock.json"
    ];
    settings = {
      lineWidth = 80;
      plugins = pkgs.dprint-plugins.getPluginList (
        plugins: with plugins; [
          dprint-plugin-markdown
          dprint-plugin-json
          dprint-plugin-toml
          g-plane-pretty_yaml
        ]
      );
      # dprint plugin defaults: json=2, toml=2, yaml(pretty_yaml)=2,
      # markdown lineWidth=80 + emphasis/list defaults are fine as-is.
      # Only override json+toml indent to match the rest of the repo's 4-space style.
      json.indentWidth = 4;
      toml.indentWidth = 4;
    };
  };
  # markdownlint-cli2 stays as an advisory linter (no --fix) for rules dprint
  # doesn't enforce: MD026 (heading trailing punctuation) and MD034 (bare URLs).
  settings.formatter.markdownlint = {
    command = "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2";
    includes = [ "*.md" ];
  };
}
