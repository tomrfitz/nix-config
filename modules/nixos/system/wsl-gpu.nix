{
  config,
  lib,
  pkgs,
  user,
  isWSL,
  ...
}:
let
  cfg = config.trf.wsl.gpu;
  wslLibPath = "/usr/lib/wsl/lib";
  mkWslLibEnv = enabled: lib.mkIf enabled { LD_LIBRARY_PATH = lib.mkForce wslLibPath; };
in
{
  options.trf.wsl.gpu.enable = lib.mkEnableOption "WSL GPU passthrough and container runtime wiring";

  config = lib.mkIf (isWSL && cfg.enable) {
    programs.nix-ld.enable = lib.mkDefault true;

    # Wire WSL's Windows GPU userspace into NixOS.
    wsl.useWindowsDriver = lib.mkDefault true;
    hardware.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };

    # Keep WSL-provided CUDA/NVENC/NVML userspace discoverable for shells and services.
    environment.sessionVariables = {
      LD_LIBRARY_PATH = lib.mkAfter wslLibPath;
      MESA_D3D12_DEFAULT_ADAPTER_NAME = lib.mkDefault "NVIDIA";
    };

    users.users.${user}.extraGroups = lib.mkAfter [
      "video"
      "render"
    ];

    virtualisation.podman = {
      enable = lib.mkDefault true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    virtualisation.oci-containers.backend = "podman";

    hardware.nvidia-container-toolkit = {
      enable = lib.mkDefault true;
      suppressNvidiaDriverAssertion = lib.mkDefault true;
    };

    # New Ollama module expects GPU flavor via package selection.
    services.ollama.package = lib.mkDefault pkgs.ollama-cuda;
    systemd.services.ollama.environment = mkWslLibEnv config.services.ollama.enable;
    systemd.services.plex.environment = mkWslLibEnv config.services.plex.enable;
    systemd.services.jellyfin.environment = mkWslLibEnv config.services.jellyfin.enable;

    environment.systemPackages = with pkgs; [
      cudaPackages.cudatoolkit
      libva-utils
      nvidia-container-toolkit
      vulkan-tools
    ];
  };
}
