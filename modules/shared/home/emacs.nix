{
  pkgs,
  ...
}:
{
  # Deploy vanilla Emacs config to XDG location (~/.config/emacs/)
  # Emacs 29+ natively supports XDG — no ~/.emacs.d/ needed
  xdg.configFile."emacs" = {
    source = ../../../config/emacs;
    recursive = true;
  };

  home.packages = with pkgs; [
    aspell
    aspellDicts.en
  ];
}
