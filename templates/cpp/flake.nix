{
  description = "C++ project: clang-tools on PATH; strict clang-tidy/clangd tier over the global floor";

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
          # Editor-facing tools only, pinned to this project's nixpkgs so the
          # .clang-tidy/.clangd here match the clangd that reads them. Add the
          # build system and compiler the project actually uses (cmake, ninja,
          # pkgs.clang or pkgs.gcc …); mkShellNoCC deliberately ships none.
          default = pkgs.mkShellNoCC {
            packages = [ pkgs.clang-tools ];
          };
        }
      );
    };
}
