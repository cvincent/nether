{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" = {
    options = {
      nether.shells = {
        fish.enable = lib.mkEnableOption "Fish shell";

        # TODO: Propagate this where we currently reference fish
        default = lib.mkOption {
          type = lib.types.enum [
            null
            "fish"
          ];
          default = null;
        };
      };
    };
  };

  imports = [ (import ./fish { name = "fish"; }) ];
}
