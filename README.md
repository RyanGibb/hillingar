
To build a [MirageOS](https://mirage.io) unikernel with [nix](https://nixos.org):
```
$ git clone <...>/<unikernel-name>.git
$ cd <unikernel-name>
$ nix flake new . -t github:/RyanGibb/hillingar
$ sed -i 's/UNIKERNEL-NAME/<unikernel-name>/g' flake.nix
$ nix build .#<target>
```

