{
  hostName,
  user,
  lib,
  pkgs,
  ...
}:
{
  system.stateVersion = "26.05";
  networking.hostName = hostName;

  wsl = {
    enable = true;
    defaultUser = user;
    interop = {
      register = true;
      includePath = true;
    };
  };

  trf.wsl.gpu.enable = true;

  # 1Password service account — resolves op:// references headlessly (boot, services, cron).
  # Token bootstrapped manually: /etc/op/service-account-token (chmod 600)
  environment.extraInit = ''
    if [ -r /etc/op/service-account-token ]; then
      export OP_SERVICE_ACCOUNT_TOKEN="$(cat /etc/op/service-account-token)"
    fi
  '';

  services.ollama.enable = true;

  # ── Cloudflare Tunnel (exposes homelab services outside eduroam) ───────
  # Routes managed in Cloudflare Zero Trust dashboard; token resolved via
  # 1Password service account at service start.
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 5;
      LoadCredential = "op-sa-token:/etc/op/service-account-token";
      StateDirectory = "cloudflared";
    };
    environment.HOME = "/var/lib/cloudflared";
    script = ''
      export OP_SERVICE_ACCOUNT_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/op-sa-token")"
      TOKEN="$(${pkgs._1password-cli}/bin/op read "op://d2kparnm4436vrbora6wnty6pm/lfxqpbrqybsjifdky766t35pcy/password")"
      exec ${pkgs.cloudflared}/bin/cloudflared tunnel run --token "$TOKEN"
    '';
  };

  trf.homelab = {
    enable = true;
    bookshelf.enable = true;
    paths = {
      mediaRoot = lib.mkDefault "/mnt/z/data/media";
      usenetRoot = lib.mkDefault "/mnt/k/data/usenet";
      torrentsRoot = lib.mkDefault "/mnt/k/data/torrents";
      booksRoot = lib.mkDefault "/mnt/z/data/media/books";
    };
  };

  # Homelab services — enable individually, conventions layered by homelab modules.
  services = {
    bazarr.enable = true;
    # REVISIT(upstream): re-enable calibre; ref: qmake build failure (calibre pkg) + flask-limiter (calibre-web); checked: 2026-02-26
    # calibre-server.enable = true;
    # calibre-web.enable = true;
    lidarr.enable = true;
    plex.enable = true;
    radarr.enable = true;
    # readarr replaced by bookshelf (Readarr fork with Hardcover metadata)
    # readarr.enable = true;
    sabnzbd.enable = true;
    sonarr.enable = true;
    tautulli.enable = true;
    recyclarr.enable = true;
  };
}
