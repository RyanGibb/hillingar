{
  description = "A MirageOS Unikernel";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";

  #inputs.opam-nix.url = "github:RyanGibb/opam-nix";
  inputs.opam-nix.url = "/home/ryan/projects/opam-nix";
  inputs.opam-nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.opam-nix.inputs.flake-utils.follows = "flake-utils";

  inputs.opam2json.url = "github:tweag/opam2json";
  inputs.opam2json.inputs.nixpkgs.follows = "nixpkgs";
  inputs.opam-nix.inputs.opam2json.follows = "opam2json";

  # beta so pin commit
  inputs.nix-filter.url = "github:numtide/nix-filter/3e1fff9";

  inputs.opam-repository = {
    url = "github:ocaml/opam-repository";
    flake = false;
  };
  inputs.opam-nix.inputs.opam-repository.follows = "opam-repository";
  inputs.opam-overlays = {
    url = "github:dune-universe/opam-overlays";
    flake = false;
  };
  inputs.opam-nix.inputs.opam-overlays.follows = "opam-overlays";

  outputs = { self, nixpkgs, flake-utils, opam-nix, opam2json,
      nix-filter, opam-repository, opam-overlays, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
        inherit (opam-nix.lib.${system}) queryToScope buildOpamMonorepo buildOpamProject opamRepositoryFiltered;
        inherit (lib.attrsets) mapAttrsToList mapAttrs' nameValuePair;
        # need to know package name
        unikernel-name = "hello";
        mirage-dir = ".";
      in {
        legacyPackages = let

          # run `mirage configure` on source,
          # with mirage, dune, and ocaml from `opam-nix`
          configureSrcFor = target:
            # Get mirage tool and dependancies from opam.
            # We could also get them from nixpkgs but they may not be up to date.
            let configure-scope = queryToScope { } { mirage = "*"; }; in
            pkgs.stdenv.mkDerivation {
              name = "configured-src";
              # only copy these files and only rebuild when they change
              src = with nix-filter.lib;
                filter {
                  root = self;
                  exclude = [
                    (inDirectory "_build")
                    (inDirectory "dist")
                    (inDirectory "duniverse")
                    (inDirectory "${mirage-dir}/mirage")
                    "dune"
                    "dune.build"
                    "dune.config"
                    "dune-project"
                    "dune-workspace"
                    "Makefile"
                    "flake.nix"
                    "flake.lock"
                  ];
                };
              buildInputs = with configure-scope; [ mirage ];
              nativeBuildInputs = with configure-scope; [ dune ocaml ];
              phases = [ "unpackPhase" "configurePhase" "installPhase" "fixupPhase" ];
              configurePhase = ''
                mirage configure -f ${mirage-dir}/config.ml -t ${target}
                # Rename the opam file for package name consistency
                # And move to root so a recursive search for opam files isn't required
                cp ${mirage-dir}/mirage/${unikernel-name}-${target}.opam ${unikernel-name}.opam
              '';
              installPhase = "cp -R . $out";
            };

          # collect all dependancy sources in a scope
          mkScopeMonorepo = src: buildOpamMonorepo { } src { };

          # read all the opam files from the configured source and build the ${unikernel-name} package
          mkScopeOpam = src:
            let
              scope = buildOpamProject { } unikernel-name src { };
              overlay = final: prev: {
                ${unikernel-name} = prev.${unikernel-name}.overrideAttrs (_ :
                  let monorepo-scope = mkScopeMonorepo src; in
                  {
                    phases = [ "unpackPhase" "preBuild" "buildPhase" "installPhase" ];
                    preBuild =
                      let
                        # TODO get dune build to pick up symlinks
                        createDep = name: path: "cp -r ${path} duniverse/${name}";
                        createDeps = mapAttrsToList createDep monorepo-scope;
                        createDuniverse = builtins.concatStringsSep "\n" createDeps;
                      in
                    ''
                      # find solo5 toolchain
                      ${if final ? ocaml-solo5 then
                        "export OCAMLFIND_CONF=\"${final.ocaml-solo5}/lib/findlib.conf\""
                      else ""}
                      # create duniverse
                      mkdir duniverse
                      echo '(vendored_dirs *)' > duniverse/dune
                      ${createDuniverse}
                    '';
                    buildPhase = ''
                      dune build ${mirage-dir}
                    '';
                    installPhase = ''
                      mkdir $out
                      cp -L ./dist/${unikernel-name}* $out/
                    '';
                  }
                );
              };
            in scope.overrideScope' overlay;

          targets = [ "xen" "qubes" "unix" "macosx" "virtio" "hvt" "spt" "muen" "genode" ];
          mapTargets = mkScope:
          let
            pipeTarget = target: lib.pipe target [
              configureSrcFor
              mkScope
            ];
            mappedTargets = builtins.map (target: nameValuePair target (pipeTarget target)) targets;
          in builtins.listToAttrs mappedTargets;
          targetUnikernels = mapAttrs'
            (target: scope: nameValuePair target scope.${unikernel-name})
            (mapTargets mkScopeOpam);
          targetScopes = mapAttrs'
            (target: scope: nameValuePair "${target}-scope" scope)
            (mapTargets mkScopeOpam);
          targetMonorepoScopes = mapAttrs'
            (target: scope: nameValuePair "${target}-monorepo" scope)
            (mapTargets mkScopeMonorepo);
        in targetUnikernels // targetScopes // targetMonorepoScopes
        // { opamRepositoryFiltered = opamRepositoryFiltered; };

        defaultPackage = self.legacyPackages.${system}.unix;

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

