{
  pkgs,
  lib,
  ...
}:
{
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
        select = [
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
          "DOC"
          "D"
          "UP"
        ];
        ignore = [ ];
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
