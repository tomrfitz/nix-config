{
  config,
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

  # ── sops-nix: decrypt secrets from repo at activation ─────────────────
  sops = {
    defaultSopsFile = ../../secrets/trfwsl.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  sops.secrets."cloudflared/tunnel-token" = { };

  services.ollama.enable = true;

  # ── Cloudflare Tunnel (exposes homelab services outside eduroam) ───────
  # Routes managed in Cloudflare Zero Trust dashboard; token decrypted by
  # sops-nix to /run/secrets/ at activation.
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 5;
      StateDirectory = "cloudflared";
    };
    environment.HOME = "/var/lib/cloudflared";
    script = ''
      exec ${pkgs.cloudflared}/bin/cloudflared tunnel run \
        --token-file ${config.sops.secrets."cloudflared/tunnel-token".path}
    '';
  };

  trf.homelab = {
    enable = true;
    bookshelf.enable = true;
    spliit.enable = true;
    paths = {
      mediaRoot = lib.mkDefault "/mnt/z/data/media";
      usenetRoot = lib.mkDefault "/mnt/k/data/usenet";
      torrentsRoot = lib.mkDefault "/mnt/k/data/torrents";
      booksRoot = lib.mkDefault "/mnt/k/data/media/books";
    };
    vpn = {
      enable = true;

      excludedServices = [
        # tailscaled needs split-tunnel bypass so it can reach the control
        # plane during initial auth — the nftables fwmark rules alone don't
        # cover bootstrap before tailscale0 exists
        "tailscaled"
        "cloudflared-tunnel"

        # suspect to get rate-limited
        "sonarr"
        "radarr"
        "lidarr"
        "bazarr"
        "jellyseerr"
        "recyclarr"

        "tautulli"
        "plex"
        "jellyfin"
        "immich"
        "tandoor-recipes"

        # OCI containers — image pulls fail through VPN
        "podman"
        "podman-spliit"
        "podman-bookshelf"
      ];
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
    jellyfin.enable = true;
    jellyseerr.enable = true;
    immich.enable = true;
    sabnzbd.enable = true;
    sonarr.enable = true;
    tautulli.enable = true;
    recyclarr.enable = true;
    minecraft-server.enable = true;
    tandoor-recipes.enable = true;
  };
}
