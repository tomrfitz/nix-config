# Fix vesktop build on macOS — codesign not available in Nix sandbox.
# REVISIT(upstream): remove this overlay after nixpkgs-unstable includes
# https://github.com/NixOS/nixpkgs/pull/489725;
# checked: 2026-02-20
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  vesktop = prev.vesktop.overrideAttrs (old: {
    postConfigure = "";
    buildPhase =
      builtins.replaceStrings [ "-c.electronVersion=" ] [ "-c.mac.identity=null -c.electronVersion=" ]
        old.buildPhase;
  });
}
