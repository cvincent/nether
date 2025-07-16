{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" = {
    options = {
      nether.terminals = {
        kitty.enable = lib.mkEnableOption "Kitty terminal emulator";

        # TODO: Propagate this where we currently reference kitty
        default = lib.mkOption {
          type = lib.types.enum [
            null
            "kitty"
          ];
          default = null;
        };
      };
    };
  };

  imports = [ (import ./kitty { name = "kitty"; }) ];
}
