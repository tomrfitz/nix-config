# Fix vesktop build on macOS — codesign not available in Nix sandbox.
# Upstream: https://github.com/NixOS/nixpkgs/pull/489725
# Remove once that PR lands in nixpkgs-unstable.
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  vesktop = prev.vesktop.overrideAttrs (old: {
    postConfigure = "";
    buildPhase =
      builtins.replaceStrings [ "-c.electronVersion=" ] [ "-c.mac.identity=null -c.electronVersion=" ]
        old.buildPhase;
  });
}
