{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opam-nix.url = "github:tweag/opam-nix";
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";
    opam-nix.inputs.flake-utils.follows = "flake-utils";

    opam2json.url = "github:tweag/opam2json";
    opam2json.inputs.nixpkgs.follows = "nixpkgs";
    opam-nix.inputs.opam2json.follows = "opam2json";

    # beta so pin commit
    nix-filter.url = "github:numtide/nix-filter/3e1fff9";

    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    opam-nix.inputs.opam-repository.follows = "opam-repository";
    opam-overlays = {
      url = "github:dune-universe/opam-overlays";
      flake = false;
    };
    opam-nix.inputs.opam-overlays.follows = "opam-overlays";
  };

  outputs =
    { self, nixpkgs, flake-utils, opam-nix, opam2json, nix-filter,
      opam-repository, opam-overlays, ... }@inputs:
    {
      defaultTemplate.path = ./template;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        opam-nix = inputs.opam-nix.lib.${system};
        mirage-nix = import ./src/mirage.nix
          { inherit pkgs lib flake-utils opam-nix opam2json nix-filter
          opam-repository opam-overlays; };
      in {
        lib = mirage-nix;
      });
}
