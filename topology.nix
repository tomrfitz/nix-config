{ ... }:
{
  # Non-NixOS nodes can still be modeled here so the rendered graph reflects
  # the full environment around nixosConfigurations.
  nodes = {
    trfmbp = {
      name = "trfmbp";
      deviceType = "device";
      hardware.info = "aarch64-darwin";
    };

    internet = {
      name = "Internet";
      deviceType = "internet";
    };
  };

  networks.tailscale = {
    name = "Tailscale";
    cidrv4 = "100.64.0.0/10";
  };

  # Add physical/logical links over time, e.g.:
  # nodes.trfnix.interfaces.eth0.physicalConnections = [
  #   { node = "internet"; interface = "wan"; }
  # ];
}
