# A Rex server for a headless Linux host, listed per host in flake.nix.
# Personal mode: the server runs as the login user, in a systemd user service
# (`journalctl --user -u rex`), and joins the tailnet as its own node,
# `<host>-rex`, as the Macs' Rex app does. Only the account that enrolled the
# node may connect. Enrolling is by hand, once: AGENTS.md § Rex.
# https://www.superlogical.com/rex/docs/linux/server-modes
{
  hostName,
  user,
  ...
}:
{
  # A user service starts at the first login and stops, with every session,
  # at the last logout; lingering starts it at boot and keeps it.
  users.users.${user}.linger = true;

  home-manager.users.${user}.services.rex = {
    enable = true;
    tailscale = {
      enable = true;
      hostname = "${hostName}-rex";
    };
  };
}
