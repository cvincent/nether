{ name }:
{ lib, ... }:
{
  imports = [ (import ./neovim { name = "neovim"; }) ];

  flake.nixosModules."${name}" = {
    options = {
      nether.editors = {
        neovim.enable = lib.mkEnableOption "NeoVim - the greatest editor";

        # TODO: Follow the example of shells.nix and terminals.nix
        default = lib.mkOption {
          type = lib.types.enum [
            null
            "neovim"
          ];
          default = null;
        };
      };
    };
  };
}
