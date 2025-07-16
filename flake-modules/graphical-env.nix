{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.graphicalEnv = {
          enable = lib.mkEnableOption "Graphical environment";
          enableGnomeKeyring = lib.mkEnableOption "Gnome keyring service";

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

        security.pam.services.login.enableGnomeKeyring = config.nether.graphicalEnv.enableGnomeKeyring;
        services.gnome.gnome-keyring.enable = config.nether.graphicalEnv.enableGnomeKeyring;
      };
    };
}
