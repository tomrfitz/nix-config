_: {
  # ── Python: the global floor ───────────────────────────────────────────
  # ruff and ty are on PATH from here so a loose script gets diagnostics in
  # the editor (rass/eglot spawns them by name) and `dprint fmt` can exec
  # `ruff format`. Inside a project the devShell's copy shadows them on PATH.
  # The ruff settings apply only where no project config exists;
  # templates/python-uv layers the strict tier on top with `extend`.
  #
  # Floor rule: a rule earns its place here only if you would accept its
  # diagnostic in someone else's script. Opinion — annotations everywhere,
  # no print, TODO format, import style, size budgets — is the template's.
  programs.ty.enable = true;

  programs.ruff = {
    enable = true;
    settings = {
      exclude = [
        ".bzr"
        ".direnv"
        ".eggs"
        ".git"
        ".git-rewrite"
        ".hg"
        ".ipynb_checkpoints"
        ".mypy_cache"
        ".nox"
        ".pants.d"
        ".pyenv"
        ".pytest_cache"
        ".pytype"
        ".ruff_cache"
        ".svn"
        ".tox"
        ".venv"
        ".vscode"
        "__pypackages__"
        "_build"
        "buck-out"
        "build"
        "dist"
        "node_modules"
        "site-packages"
        "venv"
      ];
      "line-length" = 80;
      "indent-width" = 4;

      lint = {
        # pydoclint (DOC) is preview-only; explicit-preview-rules keeps every
        # other unstable rule off, which is why the DOC codes are spelled out.
        preview = true;
        "explicit-preview-rules" = true;
        select = [
          # ── Baseline (unchanged since before 2026-09) ──────────────────
          "E"
          "F"
          "W"
          "C"
          "D"
          "I"
          "NPY"
          "A"
          "RUF"
          "G"
          "S"
          "PYI"
          "B"
          "C4"
          "EXE"
          "FIX"
          "ICN"
          "Q"
          "RET"
          "SLF"
          "SIM"
          "PD"
          "N"
          "PERF"
          "UP"
          # pydoclint: docstring ↔ signature agreement. Only fires where a
          # docstring already has sections, so it costs nothing on scripts.
          "DOC102"
          "DOC201"
          "DOC202"
          "DOC402"
          "DOC403"
          "DOC501"
          "DOC502"
          # ── Reads one way, runs another (added 2026-09-07) ─────────────
          "ISC" # implicit concatenation: the missing-comma bug (ISC002 stays off; the formatter joins multi-line concatenations)
          "COM818" # trailing comma on a bare tuple: `x = 1,`
          "DTZ" # naive datetimes read as local time and aren't
          "YTT" # sys.version comparisons that don't mean what they look like
          "BLE" # blind `except:`
          "RSE" # `raise X` not `raise X()`
          "PLE" # pylint errors
          "PLW" # pylint warnings: else-on-loop-without-break, self-assignment, shadowed loop variables…
          "PIE" # duplicate class fields, needless `pass`
          "FLY" # static "".join() → f-string
          "FURB" # single-meaning modern spellings (stable subset)
          "T10" # debugger imports
          "PGH" # blanket `noqa` / `type: ignore` without a code
          "LOG" # logging misuse
          "ASYNC" # blocking calls inside async defs
        ];
        ignore = [
          "S101" # assert is the right tool for invariants and tests
        ];
        "per-file-ignores" = {
          "tests/**" = [
            "D"
            "S"
            "SLF"
          ];
          "__init__.py" = [ "D104" ];
        };
        pydocstyle.convention = "pep257";
        fixable = [ "ALL" ];
        unfixable = [ ];
        "dummy-variable-rgx" = "^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$";
      };

      format = {
        "quote-style" = "double";
        "indent-style" = "space";
        "skip-magic-trailing-comma" = false;
        "line-ending" = "auto";
        "docstring-code-format" = true;
        "docstring-code-line-length" = 80;
      };
    };
  };
}
