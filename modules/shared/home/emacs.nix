{
  pkgs,
  homebrew-emacs-plus,
  ...
}:
let
  patchDir = "${homebrew-emacs-plus}/patches/emacs-30";

  # macOS: emacs30 + emacs-plus patches (system appearance, rounded frames,
  # window role fix, NS color fix)
  # NixOS: stock emacs30
  emacs =
    if pkgs.stdenv.isDarwin then
      (pkgs.emacs30.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          "${patchDir}/system-appearance.patch"
          "${patchDir}/round-undecorated-frame.patch"
          "${patchDir}/fix-window-role.patch"
          "${patchDir}/fix-ns-x-colors.patch"
        ];
      }))
    else
      pkgs.emacs30;
in
{
  # Deploy vanilla Emacs config to XDG location (~/.config/emacs/)
  # Emacs 29+ natively supports XDG — no ~/.emacs.d/ needed
  xdg.configFile."emacs" = {
    source = ../../../config/emacs;
    recursive = true;
  };

  home.packages = [
    emacs
    pkgs.aspell
    pkgs.aspellDicts.en
    pkgs.aspellDicts.it
  ];

  # Emacs daemon: launchd (macOS) / systemd (NixOS)
  services.emacs = {
    enable = true;
    package = emacs;
  };
}
