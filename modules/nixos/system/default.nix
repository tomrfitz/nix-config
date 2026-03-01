{
  lib,
  user,
  isWSL,
  ...
}:
{
  imports = [
    ./user.nix
    ./homelab
  ]
  ++ lib.optionals (!isWSL) [ ./hardening.nix ]
  ++ lib.optionals isWSL [
    ./wsl-gpu.nix
    # Stop WSL from overwriting /etc/resolv.conf — Tailscale manages it for MagicDNS.
    # Declare nameservers (satisfies nixos-wsl's check) but disable resolvconf so
    # NixOS doesn't fight Tailscale for ownership of the file.
    {
      wsl.wslConf.network.generateResolvConf = false;
      networking.resolvconf.enable = false;
      networking.nameservers = [
        "100.100.100.100" # Tailscale MagicDNS
        "1.1.1.1"
      ];
    }
  ];

  programs.zsh.enable = true;

  programs.nh.enable = true;

  # ── Time zone ─────────────────────────────────────────────────────────
  # Use automatic timezone detection (sets time.timeZone = null internally)
  # Falls back to America/New_York if location detection fails
  services.automatic-timezoned.enable = true;

  # ── Tailscale ──────────────────────────────────────────────────────────
  services.tailscale.enable = true;

  # ── SSH ───────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      MaxAuthTries = 3;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };

  # ── 1Password CLI ────────────────────────────────────────────────────
  programs._1password.enable = true;
}
