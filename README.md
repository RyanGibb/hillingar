
# Hillingar

<div align="center">
    <img width="200" src="readme/nix-snowflake.svg" alt="Nix snowflake">
    <img width="200" src="readme/mirage-logo.svg" alt="Mirage logo"></td>
</div>

To build a [MirageOS](https://mirage.io) unikernel with [Nix](https://nixos.org):
```bash
# create a flake from Hillingar's default template
$ nix flake new . -t github:/RyanGibb/hillingar
# substitute the name of the unikernel you're building
$ sed -i 's/throw "Put the unikernel name here"/"<unikernel-name>"/g' flake.nix
# build the unikernel with Nix for a particular target
$ nix build .\#<target>
```

Read more at [ryan.freumh.org/blog/hillingar](https://ryan.freumh.org/blog/hillingar).

See an example at [RyanGibb/mirage-hello-hillingar](https://github.com/RyanGibb/mirage-hello-hillingar).

Built on top of [tweag/opam-nix/pull/18](https://github.com/tweag/opam-nix/pull/18).
