{ config, ... }:
{
  # XDG Base Directory compliance for tools that hardcode $HOME paths.
  # Canonical reference: https://wiki.archlinux.org/title/XDG_Base_Directory
  home.sessionVariables = {
    # Shell history / readline
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    INPUTRC = "${config.xdg.configHome}/readline/inputrc";

    # Rust
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";

    # Go
    GOPATH = "${config.xdg.dataHome}/go";
    GOMODCACHE = "${config.xdg.cacheHome}/go/mod";

    # Node (npm's rc: programs.npm below)
    NODE_REPL_HISTORY = "${config.xdg.stateHome}/node/repl_history";

    # Python (3.13+ honors PYTHON_HISTORY natively)
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
    PYTHONPYCACHEPREFIX = "${config.xdg.cacheHome}/python";

    # Linters / formatters
    RUFF_CACHE_DIR = "${config.xdg.cacheHome}/ruff";

    # Data / scientific tooling
    MPLCONFIGDIR = "${config.xdg.configHome}/matplotlib";
    IPYTHONDIR = "${config.xdg.configHome}/ipython";
    JUPYTER_PLATFORM_DIRS = "1"; # Jupyter 5+ uses XDG when this is set

    # LLM model storage (Ollama config stays in ~/.ollama; models relocate)
    OLLAMA_MODELS = "${config.xdg.dataHome}/ollama/models";

    # ncurses terminfo (user-installed entries)
    TERMINFO = "${config.xdg.dataHome}/terminfo";

    # Databases
    SQLITE_HISTORY = "${config.xdg.stateHome}/sqlite/history";
    PSQL_HISTORY = "${config.xdg.stateHome}/psql/history";
    PSQLRC = "${config.xdg.configHome}/pg/psqlrc";

    # Misc CLI
    WGETRC = "${config.xdg.configHome}/wget/wgetrc";
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";
  };

  # With preferXdgDirectories the rc lands in ~/.config/npm/npmrc and the module
  # sets NPM_CONFIG_USERCONFIG; cache/prefix/logs default to $HOME-relative
  # paths, so the rc relocates them. No package: node comes from devShells.
  programs.npm = {
    enable = true;
    package = null;
    settings = {
      prefix = "${config.xdg.dataHome}/npm";
      cache = "${config.xdg.cacheHome}/npm";
      init-module = "${config.xdg.configHome}/npm/config/npm-init.js";
      logs-dir = "${config.xdg.stateHome}/npm/logs";
    };
  };
}
