{
  description = "Python project: uv-managed interpreter + venv; ruff and ty on PATH";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      forEachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
      ];
    in
    {
      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            # uv owns the interpreter (.python-version) and the venv; nix only
            # supplies the editor-facing tools. ruff and ty must be on PATH *by
            # name*: the global rass multiplexer (eglot) spawns them from this
            # shell's environment.
            packages = [
              pkgs.uv
              pkgs.ruff
              pkgs.ty
            ];
            # uv sync is idempotent: a no-op once uv.lock and .venv are current,
            # so re-running it on every direnv reload is cheap.
            shellHook = ''
              uv sync
              source .venv/bin/activate
            '';
          };
        }
      );
    };
}
