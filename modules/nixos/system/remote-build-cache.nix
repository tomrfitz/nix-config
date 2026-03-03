{
  lib,
  hostName,
  sshPublicKey,
  pkgs,
  ...
}:
let
  builderHost = "trfwsl";
  builderUser = "remotebuild";
  builderSshKey = "/root/.ssh/trfwsl-builder";
  builderAuthorizedKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHPxRsDJF+oWSJOBoZSiz739Cd1hvN5bWKNv8xQ9ugLv root@trfnix";

  atticCacheName = "trf-infra";
  atticPort = 8484;
  atticSubstituter = "http://${builderHost}:${toString atticPort}/${atticCacheName}";
  atticPublicKey = "trf-infra:9T9hcVKDnDKKTirHMarQGhjvHLmRT4prxPb4RLRXctI=";
in
{
  config = lib.mkMerge [
    (lib.mkIf (hostName == "trfnix") {
      # Offload Linux builds to trfwsl over Tailscale/MagicDNS.
      nix.distributedBuilds = true;
      nix.settings = {
        builders-use-substitutes = true;
        extra-substituters = [ atticSubstituter ];
        extra-trusted-public-keys = [ atticPublicKey ];
      };

      nix.buildMachines = [
        {
          hostName = builderHost;
          protocol = "ssh-ng";
          sshUser = builderUser;
          sshKey = builderSshKey;
          systems = [ "x86_64-linux" ];

          # WSL generally has more CPU available than trfnix.
          maxJobs = 8;
          speedFactor = 2;

          # WSL can't reliably provide nested virtualization for kvm builds.
          supportedFeatures = [
            "nixos-test"
            "benchmark"
            "big-parallel"
          ];
        }
      ];
    })

    (lib.mkIf (hostName == builderHost) {
      users.groups.${builderUser} = { };
      users.users.${builderUser} = {
        isSystemUser = true;
        group = builderUser;
        useDefaultShell = true;
        openssh.authorizedKeys.keys = [
          builderAuthorizedKey
          sshPublicKey
        ];
      };

      nix.settings.trusted-users = lib.mkAfter [ builderUser ];

      services.atticd = {
        enable = true;
        environmentFile = "/etc/atticd.env";
        settings = {
          listen = "[::]:${toString atticPort}";
          database.url = "sqlite:///var/lib/atticd/atticd.db?mode=rwc";
          storage = {
            type = "local";
            path = "/var/lib/atticd/storage";
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ atticPort ];

      environment.systemPackages = [ pkgs.attic-client ];

      # Keep attic cache metadata discoverable for follow-up wiring on clients.
      environment.etc."attic/cache-name".text = "${atticCacheName}\n";
      environment.etc."attic/endpoint".text = "http://${builderHost}:${toString atticPort}\n";
    })
  ];
}
