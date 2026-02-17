{
  pkgs,
  lib,
  ...
}:
let
  inherit (import ./browser-policies.nix) sharedPolicies;
in
{
  programs.zen-browser = {
    enable = true;
    policies = sharedPolicies;

    darwinDefaultsId = lib.mkIf pkgs.stdenv.isDarwin "dev.zen-browser.twilight";

    profiles.default = {
      isDefault = true;

      settings = {
        # privacy
        "signon.rememberSignons" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "network.dns.disablePrefetch" = true;
        "network.http.speculative-parallel-limit" = 0;
        "network.prefetch-next" = false;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.bounceTrackingProtection.mode" = 1;

        # zen UI
        "zen.theme.use-system-colors" = true;
        "zen.theme.gradient.show-custom-colors" = true;
        "zen.theme.content-element-separation" = 0;
        "zen.view.compact.enable-at-startup" = true;

        # navigation
        "browser.ctrlTab.sortByRecentlyUsed" = true;
        "browser.download.dir" = "/Users/tomrfitz/Documents";
      };

      userChrome = builtins.readFile ../../../config/zen-userchrome.css;
      userContent = builtins.readFile ../../../config/zen-usercontent.css;

      search = {
        force = true;
        default = "ddg";
        privateDefault = "ddg";
      };
    };
  };
}
