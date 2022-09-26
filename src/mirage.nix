{ pkgs, lib, flake-utils, opam-nix, opam2json, nix-filter, opam-repository, opam-overlays, ... }:

let
  inherit (opam-nix) queryToScope buildOpamMonorepo buildOpamProject;
  inherit (pkgs.lib.attrsets) mapAttrsToList mapAttrs' nameValuePair;
in rec {
  # run `mirage configure` on source,
  # with mirage, dune, and ocaml from `opam-nix`
  configureSrcFor = unikernelName: mirageDir: src: target:
    # Get mirage tool and dependancies from opam.
    # We could also get them from nixpkgs but they may not be up to date.
    let configure-scope = queryToScope { } { mirage = "*"; }; in
    pkgs.stdenv.mkDerivation {
      name = "configured-src";
      # only copy these files and only rebuild when they change
      src = with nix-filter.lib;
      filter {
        root = src;
        exclude = [
        (inDirectory "_build")
        (inDirectory "dist")
        (inDirectory "duniverse")
        (inDirectory "${mirageDir}/mirage")
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
        mirage configure -f ${mirageDir}/config.ml -t ${target}
        # Rename the opam file for package name consistency
        # And move to root so a recursive search for opam files isn't required
        cp ${mirageDir}/mirage/${unikernelName}-${target}.opam ${unikernelName}.opam
      '';
      installPhase = "cp -R . $out";
    };

  # collect all dependancy sources in a scope
  mkScopeMonorepo = src: buildOpamMonorepo { } src { gmp = "*"; };

  # create an opam switch in a nix derivation to access opam variables,
  # like for https://github.com/mirage/ocaml-gmp/pull/18
  mkOpamSwitch = repo: pkgs.stdenv.mkDerivation {
    name = "opam-switch";
    phases = [ "buildPhase" "installPhase" ];
    nativeBuildInputs = with pkgs; [ opam ];
    buildPhase = let
      localrepo = "localrepo";
    in ''
      export HOME=$(pwd)
      # we need to copy all the files to a writable or else opam complains
      cp -r --no-preserve=mode,ownership ${repo} ${localrepo}
      # as we don't have network access,
      # use a local directory as the package repository,
      # don't install compiler,
      # and don't do opam sandboxing inside nix sandboxing
      opam init local ${localrepo} --bare --disable-sandboxing
      # TODO --bare doesn't install a default switch,
      # but `opam config subst` needs a default switch
    '';
    installPhase = ''
      mkdir $out
      cp -r .opam/* $out
    '';
  };

  # read all the opam files from the configured source and build the ${unikernelName} package
  mkScopeOpam = unikernelName: mirageDir: depexts: src:
    let
      scope = buildOpamProject { } unikernelName src { };
      opamSwitch = mkOpamSwitch opam-repository;
      overlay = final: prev: {
        "${unikernelName}" = prev.${unikernelName}.overrideAttrs (_ :
          let monorepo-scope = mkScopeMonorepo src; in {
            phases = [ "unpackPhase" "preBuild" "buildPhase" "installPhase" ];
            # TODO pick depexts of deps in monorepo
            buildInputs = prev.${unikernelName}.buildInputs ++ depexts;
            # for opam commands with `opamSwitch`
            nativeBuildInputs = with pkgs; [ opam ];
            preBuild = let
              # TODO get dune build to pick up symlinks
              createDep = name: path: "cp -r ${path} duniverse/${name}";
              createDeps = mapAttrsToList createDep monorepo-scope;
              createDuniverse = builtins.concatStringsSep "\n" createDeps;
            in ''
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
              # so opam can find .opam dir
              export HOME="$(pwd)"
              cp -r ${opamSwitch} .opam
              # don't fail on warnings
              dune build ${mirageDir} --profile release
            '';
            installPhase = ''
              mkdir $out
              cp -L ${mirageDir}/dist/${unikernelName}* $out/
            '';
          }
        );
      };
    in scope.overrideScope' overlay;

  mkUnikernelPackages = { unikernelName, mirageDir ? ".", depexts ? with pkgs; [ ] }:
    src: let
      targets = [ "xen" "qubes" "unix" "macosx" "virtio" "hvt" "spt" "muen" "genode" ];
      mapTargets = mkScope:
      let
        pipeTarget = target: lib.pipe target [
          (configureSrcFor unikernelName mirageDir src)
          mkScope
        ];
        mappedTargets = builtins.map (target: nameValuePair target (pipeTarget target)) targets;
      in builtins.listToAttrs mappedTargets;
        targetUnikernels = mapAttrs'
          (target: scope: nameValuePair target scope.${unikernelName})
          (mapTargets (mkScopeOpam unikernelName mirageDir depexts));
        targetScopes = mapAttrs'
          (target: scope: nameValuePair "${target}-scope" scope)
          (mapTargets (mkScopeOpam unikernelName mirageDir depexts));
        targetMonorepoScopes = mapAttrs'
          (target: scope: nameValuePair "${target}-monorepo" scope)
          (mapTargets mkScopeMonorepo);
    in targetUnikernels // targetScopes // targetMonorepoScopes;
}
