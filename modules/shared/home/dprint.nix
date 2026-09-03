{
  pkgs,
  lib,
  config,
  ...
}:
let
  # sql-formatter's `-c` flag accepts JSON-as-string, but dprint-plugin-exec
  # tokenizes commands itself (no shell), so the surrounding single quotes
  # get passed as part of the arg. Use a config file instead — same content,
  # works for both editor and CLI paths.
  sqlFormatterConfig = "${config.xdg.configHome}/sql-formatter/config.json";
  # WASM plugins from nixpkgs — sandbox-safe, no plugin URL fetches at runtime.
  # getPluginList yields the plugin.wasm paths directly. The selector is shared
  # with treefmt.nix (config/dprint-plugins.nix) so the two lists cannot drift.
  pluginPaths = pkgs.dprint-plugins.getPluginList (import ../../../config/dprint-plugins.nix);

  # Process plugin — fetched from URL with checksum pin. Not in nixpkgs because
  # it's a per-platform binary (not WASM), but the JSON manifest is hash-pinned
  # so reproducibility is preserved.
  execPlugin = "https://plugins.dprint.dev/exec-0.6.2.json@df98f54ffd3092b8a841aedd6d098a2651f16d0a796a40535774f1a8b4b9d463";
in
{
  # Global dprint fallback. dprint walks up the directory tree looking for a
  # project dprint.{json,jsonc}; only when none is found does it fall back here.
  # The treefmt-generated config in this repo fully overrides this — no merging.
  #
  # NB: dprint-plugin-markdown only dispatches code-fence formatting to *WASM*
  # plugins. Exec-wrapped CLIs (clang-format, nixfmt, sql-formatter, shfmt)
  # format standalone files matching their `exts` but won't be picked up for
  # ```cpp / ```nix / ```sql / ```bash fences inside markdown.
  xdg.configFile."dprint/dprint.jsonc".text = builtins.toJSON {
    lineWidth = 80;
    indentWidth = 4;
    useTabs = false;
    newLineKind = "lf";

    includes = [
      "**/*.md"
      "**/*.json"
      "**/*.jsonc"
      "**/*.toml"
      "**/*.yaml"
      "**/*.yml"
      "**/*.py"
      "**/*.ts"
      "**/*.tsx"
      "**/*.js"
      "**/*.jsx"
      "**/*.mjs"
      "**/*.cjs"
      "**/*.css"
      "**/*.scss"
      "**/*.sass"
      "**/*.less"
      "**/*.html"
      "**/*.vue"
      "**/*.svelte"
      "**/*.astro"
      "**/*.graphql"
      "**/*.gql"
      "**/Dockerfile"
      "**/*.ipynb"
      "**/*.nix"
      "**/*.c"
      "**/*.h"
      "**/*.cpp"
      "**/*.cc"
      "**/*.cxx"
      "**/*.hpp"
      "**/*.hxx"
      "**/*.java"
      "**/*.sql"
      "**/*.sh"
      "**/*.bash"
    ];
    excludes = [
      "flake.lock"
      "**/package-lock.json"
      "**/node_modules"
      "**/.direnv"
      "**/.git"
      "**/dist"
      "**/build"
      "**/target"
    ];

    typescript.quoteStyle = "preferDouble";

    # Exec commands mirror the formatters wired into Zed (modules/shared/home/desktop.nix)
    # so the same style applies whether you format via editor or `dprint fmt`.
    exec = {
      cwd = "\${configDir}";
      commands = [
        {
          command = "clang-format --assume-filename={{file_path}}";
          exts = [
            "c"
            "h"
            "cpp"
            "cc"
            "cxx"
            "hpp"
            "hxx"
            "java"
          ];
          stdin = true;
        }
        {
          command = "nixfmt";
          exts = [ "nix" ];
          stdin = true;
        }
        {
          command = "sql-formatter --language transactsql --config ${sqlFormatterConfig}";
          exts = [ "sql" ];
          stdin = true;
        }
        {
          # Indent and simplify come from .editorconfig (found via --filename).
          command = "shfmt --filename {{file_path}} -";
          exts = [
            "bash"
            "sh"
          ];
          stdin = true;
        }
      ];
    };

    plugins = pluginPaths ++ [ execPlugin ];
  };

  # Shared style for sql-formatter (used by dprint exec, Zed, Emacs sqlformat).
  xdg.configFile."sql-formatter/config.json".text = builtins.toJSON {
    tabWidth = 4;
    keywordCase = "upper";
    dataTypeCase = "upper";
    functionCase = "upper";
  };

  # clang-format is needed by the exec plugin (the only formatter binary used
  # above that wasn't already in shared packages).
  home.packages = [ pkgs.clang-tools ];
}
