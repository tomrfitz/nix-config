{ pkgs, ... }:
{
  programs.zsh.enable = true;

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };

  # ── Display / Sway ───────────────────────────────────────────────────
  programs.sway.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      user = "greeter";
    };
  };

  # ── Time zone ─────────────────────────────────────────────────────────
  # Use automatic timezone detection (sets time.timeZone = null internally)
  # Falls back to America/New_York if location detection fails
  services.automatic-timezoned.enable = true;

  # ── Sun-based screen temperature (blue light filter) ─────────────────
  # Blue light filter for Wayland - adjusts screen temperature based on sun position
  services.wlsunset = {
    enable = true;
    provider = "geoclue2"; # Auto-detect location
    temperature = {
      day = 6500;
      night = 3000;
    };
  };

  # ── Audio ─────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ── Hardware ──────────────────────────────────────────────────────────
  security.polkit.enable = true;
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.sensor.iio.enable = true; # accelerometer (auto-rotate)

  # ── Power management ──────────────────────────────────────────────────
  services.thermald.enable = true;
  services.tlp.enable = true;
  services.acpid.enable = true;

  # Backlight control for unprivileged users
  programs.light.enable = true;

  # ── Tailscale ──────────────────────────────────────────────────────────
  services.tailscale.enable = true;

  # ── SSH ───────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # ── 1Password ─────────────────────────────────────────────────────────
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "tomrfitz" ];
  };

  # ── Secrets/keyring ───────────────────────────────────────────────────
  # Required for 1Password to persist 2FA session and other secrets
  services.gnome.gnome-keyring.enable = true;

  # Allow Zen Browser to communicate with 1Password
  # (1Password verifies browser binaries against an allowlist)
  # Note: Firefox is built-in, but Zen and other forks need explicit allowlisting
  environment.etc."1password/custom_allowed_browsers".text = ''
    zen
    zen-bin
    zen-twilight
  '';
  environment.etc."1password/custom_allowed_browsers".mode = "0755";

  # ── Face authentication (howdy) ───────────────────────────────────────
  services.linux-enable-ir-emitter.enable = true;
  services.howdy = {
    enable = true;
    control = "sufficient";
    settings.video = {
      # Verify with: v4l2-ctl --list-devices (find the IR camera)
      device_path = "/dev/video2";
    };
  };
  security.pam.services = {
    sudo.howdy.enable = true;
    login.howdy.enable = true;
    swaylock.howdy.enable = true;
  };
}
