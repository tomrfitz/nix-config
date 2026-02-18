{ ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 256 * 1024 * 1024; # 256 MiB (default 64 MiB)
  };
}
