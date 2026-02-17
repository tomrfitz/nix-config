{
  config,
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

    profiles.twilight = {
      id = 0;
      name = "default";
      path = "owckmgyi.Default (twilight)";
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
        default = "Kagi";
        privateDefault = "Kagi";
        engines.Kagi = {
          urls = [ { template = "https://kagi.com/search?q={searchTerms}"; } ];
          icon = "https://kagi.com/favicon.ico";
          definedAliases = [ "@k" ];
        };
      };
    };
  };

  # Zen Browser requires write access to profiles.ini (to store install hashes
  # and lock flags). Home-manager deploys it as a read-only nix store symlink,
  # which causes Zen to loop on "Changes not saved". Replace the symlink with a
  # mutable copy after link generation so Zen can update it freely.
  home.activation.makeZenProfilesMutable = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    zenProfiles="${config.home.homeDirectory}/Library/Application Support/zen/profiles.ini"
    if [ -L "$zenProfiles" ]; then
      realPath=$(readlink "$zenProfiles")
      rm "$zenProfiles"
      cp "$realPath" "$zenProfiles"
      chmod u+w "$zenProfiles"
    fi
  '';
}
