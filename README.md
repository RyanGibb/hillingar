
# Hillingar

<style>
table {
    border-collapse: collapse;
}
table, th, td {
   border: 1px solid black;
}
blockquote {
    border-left: solid blue;
    padding-left: 10px;
}
</style>

<div align="center">
    <table style="border: none;">
        <tbody>
            <tr>
                <td style="text-align: center;"><img width="200" src="readme/nix-snowflake.svg" alt="Nix snowflake"></td>
                <td style="text-align: center;"><img width="200" src="readme/mirage-logo.svg" alt="Mirage logo"></td>
            </tr>
        </tbody>
    </table>
</div>

To build a [MirageOS](https://mirage.io) unikernel with [nix](https://nixos.org):
```
$ nix flake new . -t github:/RyanGibb/hillingar
$ sed -i 's/throw "Put the unikernel name here"/"<unikernel-name>"/g' flake.nix
$ nix build .#<target>
```
