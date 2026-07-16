{
  description = "Etherno IaC Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    flake-parts,
    nixpkgs,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];
      systems = ["x86_64-linux"];
      perSystem = {
        pkgs,
        config,
        lib,
        self',
        inputs',
        ...
      }: let
        inherit (pkgs) mkShellNoCC;
      in {
        devShells.default = mkShellNoCC {
          packages = with pkgs; [
            shellcheck
          ];
        };
        treefmt.config = {
          package = pkgs.treefmt;

          programs = {
            alejandra.enable = true;
            prettier.enable = true;
          };
        };

        formatter = config.treefmt.build.wrapper;
      };
    };
}
