{
  pkgs,
  lib,
  ...
}:
{
  programs.micro = {
    enable = true;
    settings = { };
  };

  xdg.configFile."micro/bindings.json".text = builtins.toJSON {
    "Alt-/" = "lua:comment.comment";
    "CtrlUnderscore" = "lua:comment.comment";
  };
}
