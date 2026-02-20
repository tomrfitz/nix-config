{
  pkgs,
  lib,
  config,
  user,
  ...
}:
let

  # After a specialisation activates, the current-home gcroot points to that
  # specialisation's generation (which has no sibling specialisations).
  # The systemd unit for HM always references the *base* generation from the
  # last rebuild, so we extract it from there — stable across specialisation switches.
  activateSpecialisation = name: ''
    base="$(${pkgs.systemd}/bin/systemctl show home-manager-${user}.service -p ExecStart | ${pkgs.gnugrep}/bin/grep -oP '/nix/store/[^ ]*home-manager-generation')"
    "$base/specialisation/${name}/activate"
  '';
in
{
  # ── Home-manager specialisations ────────────────────────────────────
  # Both dark and light are pre-built at rebuild time; switching is instant.
  # The base config inherits Stylix's system-level dark theme (via mkDefault).
  # Each specialisation overrides just the scheme and polarity.

  specialisation = {
    dark.configuration = {
      stylix = {
        base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/flexoki-dark.yaml";
        polarity = lib.mkForce "dark";
      };
    };

    light.configuration = {
      stylix = {
        base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/flexoki-light.yaml";
        polarity = lib.mkForce "light";
      };
    };
  };

  # ── Darkman (sunrise/sunset auto-switching) ─────────────────────────
  services.darkman = {
    enable = true;
    settings = {
      usegeoclue = true;
    };
    darkModeScripts.hm-theme = activateSpecialisation "dark";
    lightModeScripts.hm-theme = activateSpecialisation "light";
  };

  # Ensure xdg-desktop-portal is available for freedesktop dark preference
  # (darkman implements the portal interface; apps like Ghostty/Zed listen to it)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };
}
