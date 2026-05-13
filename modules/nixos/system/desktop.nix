{
  config,
  options,
  pkgs,
  lib,
  user,
  ...
}:
{
  # Required by HM xdg.portal when useUserPackages is enabled
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # ── Display / Desktop ────────────────────────────────────────────────
  programs.niri.enable = true;
  # REVISIT(upstream): remove when niri-flake raises sandbox ulimit;
  #   ref: https://github.com/sodiboo/niri-flake/issues/1300; checked: 2026-05-12
  programs.niri.package =
    let
      inherit (options.programs.niri.package) default;
    in
    default.overrideAttrs (old: {
      preCheck = (old.preCheck or "") + ''
        ulimit -n 4096
      '';
    });

  # greetd: lightweight greeter for Wayland compositors
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
      user = "greeter";
    };
  };

  # ── Audio ─────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ── Hardware ──────────────────────────────────────────────────────────
  # security.polkit and GNOME keyring also provided by nixosModules.niri
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  hardware.sensor.iio.enable = true; # accelerometer (auto-rotate)

  # ── Power management ──────────────────────────────────────────────────
  services.thermald.enable = true;
  services.tlp.enable = true;
  services.acpid.enable = true;
  services.power-profiles-daemon.enable = lib.mkForce false;

  # Headless/server: stay awake indefinitely, lid closed or not
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    IdleAction = "ignore";
  };
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  # Backlight control for unprivileged users
  hardware.acpilight.enable = true;

  # Battery reporting for desktop shell (noctalia)
  services.upower.enable = true;

  # ── 1Password GUI ───────────────────────────────────────────────────
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
    swaylock.howdy.enable = true;
  };

  # Workaround: polkit 127 sandboxes polkit-agent-helper, blocking howdy camera access.
  # nixpkgs#486044 (merged 2026-04-02) only covers FIDO/hidraw, not video4linux —
  # video4linux needs its own upstream fix.
  # REVISIT(upstream): no upstream tracking yet — file an issue or wait;
  # related: https://github.com/NixOS/nixpkgs/pull/486044; checked: 2026-05-12
  systemd.services."polkit-agent-helper@".serviceConfig = {
    DeviceAllow = "char-video4linux rw";
    PrivateDevices = "no";
  };

  # v4l-utils for camera diagnostics (v4l2-ctl)
  environment.systemPackages = [ pkgs.v4l-utils ];
}
