# Fix zed-editor build on macOS — checkFeatures missing runtime_shaders,
# causing build.rs to invoke the proprietary Metal shader compiler (unavailable
# in the Nix sandbox).
# REVISIT(upstream): remove this overlay after nixpkgs-unstable includes
# https://github.com/NixOS/nixpkgs/pull/490957 (merge commit c724b7f);
# checked: 2026-02-20
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  zed-editor = prev.zed-editor.overrideAttrs (old: {
    cargoCheckFeatures = (old.cargoCheckFeatures or [ ]) ++ [ "gpui/runtime_shaders" ];
  });
}
