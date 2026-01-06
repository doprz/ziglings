{
  description = "Ziglings nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zig.url = "github:mitchellh/zig-overlay";
    # zls.url = "github:zigtools/zls";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { pkgs, system, ... }:
        let
          # NOTE: v0.16.0-dev.1976 is broken, see: https://codeberg.org/ziglings/exercises/issues/345
          # Using master-2025-12-28 (v0.16.0-dev.1859)
          zig = inputs.zig.packages.${system}.master-2025-12-28;
          # zls = inputs.zls.packages.${system}.zls;
        in
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (final: prev: {
                inherit zig;
              })
            ];
            config = { };
          };

          devShells.default = pkgs.mkShell {
            name = "ziglings-dev";

            packages = [
              zig
              pkgs.zls
              # zls
            ];
          };
        };
    };
}
