{ ... }:
{
  # Keep disko declarative state in-repo, but don't replace runtime
  # fileSystems/swap config until we're ready to migrate.
  disko.enableConfig = false;

  disko.devices = {
    disk.main = {
      # Update this to a stable /dev/disk/by-id path before first apply.
      device = "/dev/disk/by-id/REPLACE_WITH_TRFNIX_DISK";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "1G";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
