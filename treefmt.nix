{ pkgs, lib, ... }:
{
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  # shfmt reads indent/simplify from config/editorconfig (root symlink), the
  # same source Zed and the global dprint fallback use; flags would override it.
  programs.shfmt = {
    enable = true;
    useEditorConfig = true;
  };
  programs.just.enable = true;
  programs.statix.enable = true;
  # Lint, not format: fails fmt-check on shellcheck warnings and errors.
  programs.shellcheck = {
    enable = true;
    severity = "warning";
  };

  # dprint formats md/json/yaml/toml and (importantly) dispatches code blocks
  # embedded in markdown to the matching WASM plugin. Plugins come from
  # nixpkgs so this stays sandbox-safe (no plugin URL fetches at format/eval
  # time). The plugin selector is shared with modules/shared/home/dprint.nix
  # via config/dprint-plugins.nix.
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
      # 4-space indent across all formats; per-plugin defaults are 2, so set
      # both at the top level and individually for the ones we care about most.
      indentWidth = 4;
      plugins = pkgs.dprint-plugins.getPluginList (import ./config/dprint-plugins.nix);
      json.indentWidth = 4;
      toml.indentWidth = 4;
      typescript.quoteStyle = "preferDouble";
    };
  };
  # markdownlint-cli2 stays as an advisory linter (no --fix) for rules dprint
  # doesn't enforce: MD026 (heading trailing punctuation) and MD034 (bare URLs).
  settings.formatter.markdownlint = {
    command = "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2";
    includes = [ "*.md" ];
  };
}
