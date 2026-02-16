# Fix zed-editor build on macOS — checkFeatures missing runtime_shaders,
# causing build.rs to invoke the proprietary Metal shader compiler (unavailable
# in the Nix sandbox).
# Upstream: https://github.com/NixOS/nixpkgs/pull/490957
# Remove once that PR lands in nixpkgs-unstable.
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  zed-editor = prev.zed-editor.overrideAttrs (old: {
    cargoCheckFeatures = (old.cargoCheckFeatures or [ ]) ++ [ "gpui/runtime_shaders" ];
  });
}
