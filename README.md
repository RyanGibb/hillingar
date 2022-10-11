
# Hillingar

<div align="center">
    <img width="200" src="readme/nix-snowflake.svg" alt="Nix snowflake">
    <img width="200" src="readme/mirage-logo.svg" alt="Mirage logo"></td>
</div>

To build a [MirageOS](https://mirage.io) unikernel with [Nix](https://nixos.org):
```bash
# create a flake from this project's default template
$ nix flake new . -t github:/RyanGibb/hillingar
# substitute the name of the unikernel you're building
$ sed -i 's/throw "Put the unikernel name here"/"<unikernel-name>"/g' flake.nix
# build the unikernel with Nix
$ nix build .\#<target>
```
