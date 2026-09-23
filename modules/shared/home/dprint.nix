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
  # The selector is shared with treefmt.nix (config/dprint-plugins.nix) so the
  # two lists cannot drift.
  dprintPlugins = import ../../../config/dprint-plugins.nix pkgs;
  pluginPaths = dprintPlugins.paths;

  # Process plugin — fetched from URL with checksum pin. Not in nixpkgs because
  # it's a per-platform binary (not WASM), but the JSON manifest is hash-pinned
  # so reproducibility is preserved.
  execPlugin = "https://plugins.dprint.dev/exec-0.6.2.json@df98f54ffd3092b8a841aedd6d098a2651f16d0a796a40535774f1a8b4b9d463";
in
{
  # Global dprint fallback: the one formatter front for any file, any editor,
  # any checkout. dprint walks up the directory tree looking for a project
  # dprint.{json,jsonc}; only when none is found does it fall back here. The
  # treefmt-generated config in this repo fully overrides this — no merging.
  #
  # Plugin policy: WASM plugins for formats with no project-native config
  # (markdown, json, toml, yaml, dockerfile, …); exec-wrapped CLIs for
  # languages that have one (ruff → pyproject, clang-format → .clang-format,
  # shfmt → .editorconfig, nixfmt), because the CLI discovers the project's
  # own config from the file path while a WASM plugin only knows this file.
  # A third-party checkout therefore formats by its rules, not ours. The exec
  # plugin is listed first: the first plugin whose associations match a file
  # wins, there is no chaining.
  #
  # Markdown fences: dprint-plugin-markdown dispatches a fence only when its
  # tag is in a built-in map (python, rust, ts/js, css, toml, yaml, json,
  # dockerfile, xml, …), and does so for exec too — ```python fences go
  # through `ruff format`. Plugin 0.21.1+ adds a `tags` map for the rest;
  # config/dprint-plugins.nix pins 0.23.3 until nixpkgs catches up, so the
  # map below is live (it is gated on the version regardless).
  xdg.configFile."dprint/dprint.jsonc".text = builtins.toJSON (
    {
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
        "**/*.pyi"
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
        # No `cwd`: the README suggests ${configDir}, but this config lives in the
        # Nix store, and a markdown fence reaches exec as the relative name
        # `file.py` resolved against cwd. Leaving cwd at the invocation directory
        # (the project, from an editor or the CLI) lets `ruff format` and
        # clang-format find the project's config for fences too.
        commands = [
          {
            # --stdin-filename makes ruff discover the project's pyproject/ruff.toml
            # (falling back to the global floor), unlike the WASM ruff plugin.
            command = "ruff format --stdin-filename {{file_path}} -";
            exts = [
              "py"
              "pyi"
            ];
            stdin = true;
          }
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

      plugins = [ execPlugin ] ++ pluginPaths;
    }
    # Fence tag → extension, so the exec commands also format these fences
    # (see the header comment). The key is absent until the plugin allows it.
    // lib.optionalAttrs (lib.versionAtLeast dprintPlugins.markdown.version "0.21.1") {
      markdown.tags = {
        cpp = "cpp";
        "c++" = "cpp";
        cc = "cpp";
        c = "c";
        java = "java";
        nix = "nix";
        sh = "sh";
        bash = "sh";
        shell = "sh";
        sql = "sql";
      };
    }
  );

  # Shared style for sql-formatter (used by dprint exec, Zed, Emacs sqlformat).
  xdg.configFile."sql-formatter/config.json".text = builtins.toJSON {
    tabWidth = 4;
    keywordCase = "upper";
    dataTypeCase = "upper";
    functionCase = "upper";
  };

  # clang-format is needed by the exec plugin; ruff comes from python.nix and
  # the rest from packages.nix.
  home.packages = [ pkgs.clang-tools ];
}
