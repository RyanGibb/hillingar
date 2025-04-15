
# Hillingar

> An arctic mirage

[ryan.freumh.org/hillingar.html](https://ryan.freumh.org/hillingar.html)

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

See an example in [examples/hello](examples/hello), and build it from the project root with `nix build .\?dir=examples/hello`.
If you've already configured your unikernel with `mirage configure` and checked in into version control, pass `configured = true;` to `mkUnikernelPackages`.

Other outputs which may be useful for debugging include:

- `<target>-configured`: the project after having invoked `mirage configure`.
- `<target>-monorepo`: the result of [opam monorepo](https://github.com/tarides/opam-monorepo) that is provided to the unikernel build in the `duniverse` directory.
- `<target>-scope`: the [Nixpkgs scope](https://github.com/NixOS/nixpkgs/blob/a89c4f5411da503aedbce629be535ec2da1e7f7b/lib/customisation.nix#L417-L552) created by an opam solve for the `dune build`.
- `<target>` is an alias for `<target>-scope.<unikernel-name`.

Where target is one of xen, qubes, unix, macosx, virtio, hvt, spt, muen, or genode.

Built on top of [tweag/opam-nix/pull/18](https://github.com/tweag/opam-nix/pull/18).

