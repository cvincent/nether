{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.graphicalEnv = {
          enable = lib.mkEnableOption "Graphical environment";

          displayManager = lib.mkOption {
            type = lib.types.enum [
              null
              "gdm"
            ];
            default = null;
          };
        };

      };

      config = {
        services.xserver = lib.mkIf config.nether.graphicalEnv.enable {
          enable = true;
          displayManager.gdm.enable = config.nether.graphicalEnv.displayManager == "gdm";
        };
      };
    };
}
