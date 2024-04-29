{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    hillingar.url = "path:/home/ryan/projects/hillingar";
  };

  outputs = { self, nixpkgs, flake-utils, hillingar, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = let
          mirage-nix = (hillingar.lib.${system});
          inherit (mirage-nix) mkUnikernelPackages;
        in mkUnikernelPackages {
          unikernelName = "hello";
          # list external dependancies here
          depexts = with pkgs; [ ];
          # solve for non-trunk compiler
          monorepoQuery = { ocaml-base-compiler = "*"; };
          query = { mirage = "4.5.0"; };
        } ./.;

        defaultPackage = self.packages.${system}.unix;
      });
}
