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

    # Node
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
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

  # npm reads NPM_CONFIG_USERCONFIG for its rc, but cache/prefix/logs default
  # to $HOME-relative paths — relocate those inside the rc itself.
  xdg.configFile."npm/npmrc".text = ''
    prefix=''${XDG_DATA_HOME}/npm
    cache=''${XDG_CACHE_HOME}/npm
    init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
    logs-dir=''${XDG_STATE_HOME}/npm/logs
  '';
}
