# dprint WASM plugin selector shared by treefmt.nix (repo formatting) and
# modules/shared/home/dprint.nix (global fallback): one list, two consumers.
# Passed to pkgs.dprint-plugins.getPluginList.
plugins: with plugins; [
  dprint-plugin-markdown
  dprint-plugin-json
  dprint-plugin-toml
  g-plane-pretty_yaml
  dprint-plugin-ruff
  dprint-plugin-typescript
  g-plane-malva
  g-plane-markup_fmt
  g-plane-pretty_graphql
  dprint-plugin-dockerfile
  dprint-plugin-jupyter
]
