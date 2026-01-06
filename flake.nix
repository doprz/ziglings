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
          zig = inputs.zig.packages.${system}.master;
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
