{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.trf.homelab;
  sabnzbdSecretFile = "/var/lib/homelab-secrets/sabnzbd-auth.ini";
in
{
  config = lib.mkIf (cfg.enable && config.services.sabnzbd.enable) {
    services.sabnzbd = {
      group = "media";
      openFirewall = cfg.openFirewall;
      secretFiles = [ sabnzbdSecretFile ];
      settings.misc = {
        host = "0.0.0.0";
        inet_exposure = "api+web (auth needed)";
        html_login = true;
        enable_https = true;
      };
    };

    systemd.services.homelab-sabnzbd-auth = {
      description = "Render SABnzbd auth from 1Password";
      before = [ "sabnzbd.service" ];
      serviceConfig = {
        Type = "oneshot";
        LoadCredential = "op-sa-token:/etc/op/service-account-token";
        StateDirectory = "homelab-secrets";
        StateDirectoryMode = "0700";
        UMask = "0077";
      };
      script = ''
        set -euo pipefail
        export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/op-sa-token")"

        username="$(${pkgs._1password-cli}/bin/op read ${lib.escapeShellArg cfg.auth.usernameSecretRef})"
        password="$(${pkgs._1password-cli}/bin/op read ${lib.escapeShellArg cfg.auth.passwordSecretRef})"

        install -m 600 -o root -g root /dev/null ${sabnzbdSecretFile}
        {
          printf '[misc]\n'
          printf 'username = %s\n' "$username"
          printf 'password = %s\n' "$password"
        } > ${sabnzbdSecretFile}
      '';
    };

    systemd.services.sabnzbd = {
      requires = [ "homelab-sabnzbd-auth.service" ];
      after = [ "homelab-sabnzbd-auth.service" ];
    };
  };
}
