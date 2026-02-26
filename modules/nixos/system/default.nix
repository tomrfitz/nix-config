{
  pkgs,
  lib,
  user,
  ...
}:
{
  imports = [
    ./user.nix
    ./specialisations.nix
    ./homelab.nix
  ];

  # Cursor theme (stylix.cursor doesn't exist on darwin)
  stylix.cursor = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  programs.zsh.enable = true;

  programs.nh.enable = true;

  # ── Display / Desktop ────────────────────────────────────────────────
  services.xserver.enable = lib.mkDefault true;
  services.displayManager.gdm.enable = lib.mkDefault true;
  services.desktopManager.gnome.enable = lib.mkDefault true;

  # ── Time zone ─────────────────────────────────────────────────────────
  # Use automatic timezone detection (sets time.timeZone = null internally)
  # Falls back to America/New_York if location detection fails
  services.automatic-timezoned.enable = true;

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
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Headless/server: keep running with lid closed
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

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
    polkitPolicyOwners = [ user ];
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
  services.linux-enable-ir-emitter = {
    enable = true;
    device = "video2"; # IR camera (interface 1.2 on USB hub 0:6)
  };
  services.howdy = {
    enable = true;
    control = "sufficient";
    settings.video = {
      # Stable by-path avoids /dev/videoN renumbering across boots
      # USB 0:6 interface 1.2 = IR camera (720p HD Camera)
      device_path = "/dev/v4l/by-path/pci-0000:00:14.0-usb-0:6:1.2-video-index0";
      # IR sensor native resolution — 640x480 causes cropping/static
      frame_width = 340;
      frame_height = 340;
    };
  };
  security.pam.services = {
    sudo.howdy.enable = true;
    login.howdy.enable = true;
    polkit-1.howdy.enable = true; # 1Password uses polkit for system auth
  };

  # Workaround: polkit 127 sandboxes polkit-agent-helper, blocking camera access
  # REVISIT(upstream): remove this override once nixpkgs#486044 lands or
  # polkit-agent-helper no longer needs direct camera-device access;
  # ref: https://github.com/NixOS/nixpkgs/issues/486044; checked: 2026-02-20
  systemd.services."polkit-agent-helper@".serviceConfig = {
    DeviceAllow = "char-video4linux rw";
    PrivateDevices = "no";
  };

  # v4l-utils for camera diagnostics (v4l2-ctl)
  environment.systemPackages = [ pkgs.v4l-utils ];
}
