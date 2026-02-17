# Fix zen-browser on macOS — skip wrapFirefox to preserve code signature.
# Upstream PR: https://github.com/0xc000022070/zen-browser-flake/pull/212
# Remove once that PR merges.
#
# wrapFirefox breaks the macOS code signature, which prevents 1Password
# browser integration from recognising Zen. This overlay makes the
# unwrapped package accept the extra override args that home-manager's
# mkFirefoxModule injects (cfg, extraPolicies, pkcs11Modules), then
# provides it as the "twilight" package so the module uses it directly.
{ zen-browser }:
final: prev:
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  zen-twilight-unwrapped =
    let
      unwrapped = zen-browser.packages.${prev.stdenv.hostPlatform.system}.twilight-unwrapped;
      # The original override only accepts args defined in the package function.
      # home-manager's mkFirefoxModule calls package.override with extra args
      # (cfg, extraPolicies, pkcs11Modules) that the unwrapped package doesn't
      # know about. Filter to only the args the package actually accepts.
      acceptedArgs = unwrapped.override.__functionArgs;
    in
    unwrapped.overrideAttrs (old: {
      # Prevent stripping — it invalidates macOS code signatures and
      # /usr/bin/codesign is unavailable in the nix sandbox.
      dontStrip = true;
    }) // {
      override = newArgs:
        let
          filtered = builtins.intersectAttrs acceptedArgs (
            if builtins.isFunction newArgs then
              newArgs (builtins.intersectAttrs acceptedArgs {})
            else
              newArgs
          );
        in
        (unwrapped.override filtered).overrideAttrs (old: {
          dontStrip = true;
        });
    };
}
