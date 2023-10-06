
# Hillingar

> An arctic mirage

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

See an example in [examples/hello](examples/hello), and build it from the project root with `nix build .\?dir=examples/hello`.

Built on top of [tweag/opam-nix/pull/18](https://github.com/tweag/opam-nix/pull/18).

### Configured Unikernels

If you've already configured your unikernel with `mirage configure`, see [examples/hello-configured](examples/hello-configured) for an example of using Hillingar. Build it from the project root with `nix build .\?dir=examples/hello-configured`.
