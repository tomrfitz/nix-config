{
  config,
  lib,
  pkgs,
  hostName,
  ...
}:
let
  autoUpdateScript = pkgs.writeShellApplication {
    name = "auto-update";
    runtimeInputs = with pkgs; [
      git
      openssh
      nix
      nixos-rebuild
      attic-client
      coreutils
    ];
    text = builtins.readFile ../../../scripts/auto-update.sh;
  };
in
{
  config = lib.mkMerge [
    # ── trfwsl: update pipeline + email notification ──────────────────
    (lib.mkIf (hostName == "trfwsl") {
      sops.secrets."mail/app-pass" = {
        sopsFile = ../../../secrets/trfwsl.yaml;
      };
      sops.secrets."github/deploy-key" = {
        sopsFile = ../../../secrets/trfwsl.yaml;
      };
      sops.secrets."attic/token" = {
        sopsFile = ../../../secrets/trfwsl.yaml;
      };

      # Attic CLI config rendered by sops-nix with token interpolated
      sops.templates."attic-config".content = ''
        default-server = "local"

        [servers.local]
        endpoint = "http://127.0.0.1:8484"
        token = "${config.sops.placeholder."attic/token"}"
      '';

      programs.msmtp = {
        enable = true;
        accounts.default = {
          auth = true;
          tls = true;
          host = "smtp.gmail.com";
          port = 587;
          user = "tomrfitz@gmail.com";
          passwordeval = "cat ${config.sops.secrets."mail/app-pass".path}";
          from = "tomrfitz@gmail.com";
        };
      };

      systemd.services.auto-update = {
        description = "Nix flake auto-update pipeline";
        restartIfChanged = false;
        after = [
          "network-online.target"
          "atticd.service"
        ];
        wants = [
          "network-online.target"
          "atticd.service"
        ];
        environment.DEPLOY_KEY_PATH = config.sops.secrets."github/deploy-key".path;
        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "+${pkgs.writeShellScript "attic-config-setup" ''
            mkdir -p /root/.config/attic
            cp ${config.sops.templates."attic-config".path} /root/.config/attic/config.toml
          ''}";
          ExecStart = lib.getExe autoUpdateScript;
          TimeoutStartSec = "45min";
          StateDirectory = "auto-update";
        };
        onFailure = [ "auto-update-notify.service" ];
      };

      systemd.services.auto-update-notify = {
        description = "Send auto-update failure notification";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "auto-update-notify" ''
            {
              echo "Subject: [trfwsl] auto-update failed"
              echo "From: tomrfitz@gmail.com"
              echo "To: tomrfitz@gmail.com"
              echo ""
              echo "auto-update service failed at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
              echo ""
              ${pkgs.systemd}/bin/journalctl -u auto-update -n 80 --no-pager
            } | ${pkgs.msmtp}/bin/msmtp -a default tomrfitz@gmail.com
          '';
        };
      };

      systemd.timers.auto-update = {
        description = "Daily flake auto-update";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "*-*-* 04:45:00";
          RandomizedDelaySec = "5min";
        };
      };
    })

    # ── trfnix: scheduled rebuild from remote main ────────────────────
    (lib.mkIf (hostName == "trfnix") {
      system.autoUpgrade = {
        enable = true;
        flake = "github:tomrfitz/nix-config/main";
        dates = "*-*-* 06:30:00";
        flags = [ "--refresh" ];
      };
    })
  ];
}
