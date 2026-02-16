# Fix zed-editor build on macOS — checkFeatures missing runtime_shaders,
# causing build.rs to invoke the proprietary Metal shader compiler (unavailable
# in the Nix sandbox).
# Remove once nixpkgs adds gpui/runtime_shaders to checkFeatures.
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  zed-editor = prev.zed-editor.overrideAttrs (old: {
    cargoCheckFeatures = (old.cargoCheckFeatures or [ ]) ++ [ "gpui/runtime_shaders" ];
  });
}
