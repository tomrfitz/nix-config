{ ... }:
{
  security.pam.services.sudo_local.touchIdAuth = true;

  environment.etc."1password/custom_allowed_browsers".text = ".zen-wrapped";
}
