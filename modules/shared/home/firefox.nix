{
  pkgs,
  lib,
  ...
}:
let
  inherit (import ./browser-policies.nix) sharedPolicies;
in
{
  # ── Firefox Developer Edition ──────────────────────────────────────────
  home.packages = [
    (pkgs.wrapFirefox pkgs.firefox-devedition-unwrapped {
      extraPolicies = sharedPolicies;
    })
  ];

  # ── Firefox ────────────────────────────────────────────────────────────
  programs.firefox = {
    enable = true;
    policies = sharedPolicies;
    nativeMessagingHosts = [ pkgs._1password-gui ];
  };

  # ── Floorp ─────────────────────────────────────────────────────────────
  programs.floorp = {
    enable = true;
    policies = sharedPolicies;
    nativeMessagingHosts = [ pkgs._1password-gui ];
  };
}
