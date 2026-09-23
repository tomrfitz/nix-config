# dprint WASM plugin set shared by treefmt.nix (repo formatting) and
# modules/shared/home/dprint.nix (global fallback): one list, two consumers.
# Call with `pkgs`; `paths` is what dprint's `plugins` wants. Everything is a
# fixed-output derivation, so this stays sandbox-safe (no URL fetches at
# format time).
pkgs:
let
  inherit (pkgs.dprint-plugins) mkDprintPlugin getPluginList;
in
rec {
  # REVISIT(upstream): replace this pin with `dprint-plugin-markdown` from the
  #   plugin set once nixpkgs ships ≥ 0.21.1, the version that added the
  #   `tags` map (fence tag → extension), which is what lets exec-wrapped
  #   formatters reach ```cpp / ```nix / ```sql / ```sh fences.
  #   ref: https://github.com/dprint/dprint-plugin-markdown/pull/153;
  #   checked: 2026-09-07 (nixpkgs: 0.20.0, upstream: 0.23.3)
  markdown = mkDprintPlugin {
    pname = "dprint-plugin-markdown";
    version = "0.23.3";
    url = "https://plugins.dprint.dev/markdown-0.23.3.wasm";
    hash = "sha256-5VT4zCHoEADM4NX5SwQ6naMKemWioULHLExcfjLe7lA=";
    description = "Markdown code formatter";
    initConfig = {
      configExcludes = [ ];
      configKey = "markdown";
      fileExtensions = [ "md" ];
    };
    updateUrl = "https://plugins.dprint.dev/dprint/markdown/latest.json";
  };

  select =
    plugins: with plugins; [
      markdown
      dprint-plugin-json
      dprint-plugin-toml
      g-plane-pretty_yaml
      dprint-plugin-typescript
      g-plane-malva
      g-plane-markup_fmt
      g-plane-pretty_graphql
      dprint-plugin-dockerfile
      dprint-plugin-jupyter
    ];

  paths = getPluginList select;
}
