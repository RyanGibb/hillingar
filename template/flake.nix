{
  inputs = {
    # all the inputs we likely might want to have control over pinning
    nixpkgs.url = "github:nixos/nixpkgs";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    opam-overlays = {
      url = "github:dune-universe/opam-overlays";
      flake = false;
    };

    # make hillingar's inputs follow this flake
    hillingar.url = "github:RyanGibb/hillingar";
    hillingar.inputs.nixpkgs.follows = "nixpkgs";
    hillingar.inputs.opam-repository.follows = "nixpkgs";
    hillingar.inputs.opam-overlays.follows = "nixpkgs";
    hillingar.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, opam-repository, opam-overlays, hillingar , ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages =
          let
            mirage-nix = (hillingar.lib.${system});
            inherit (mirage-nix) mkUnikernelPackages;
          in
            mkUnikernelPackages {
              # insert unikernel name here
              unikernelName = "UNIKERNEL-NAME";
              # uncomment if mirage config.ml and unikernel.ml are in another directory
              #mirageDir = "mirage"
          };

          defaultPackage = self.packages.${system}.unix;

          # sensible default
          devShell.default = with pkgs; [
            ocaml
            opam
            dune_3
            ocamlPackages.utop
            pkg-config
            gcc
            bintools-unwrapped
            gmp
          ];
  });
}
