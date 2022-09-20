{ pkgs ? import <nixpkgs> { } }:
with pkgs;
mkShell {
  buildInputs = [
    ocaml
    opam
    dune_3
    pkg-config
    gcc
    bintools-unwrapped
    gmp
  ];
}

