{ name }:
{ lib, moduleWithSystem, ... }:
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


          extra.networkmanagerapplet.enable = lib.mkOption {
            type = lib.types.bool;
            default = config.nether.networking.networkmanager.enable;
          };
        };
      };

      config = lib.mkIf config.nether.graphicalEnv.enable {
        services.xserver = {
          enable = true;
          displayManager.gdm.enable = config.nether.graphicalEnv.displayManager == "gdm";
        };

        security.pam.services.login.enableGnomeKeyring = config.nether.graphicalEnv.enableGnomeKeyring;
        services.gnome.gnome-keyring.enable = config.nether.graphicalEnv.enableGnomeKeyring;
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.graphicalEnv.enable {
        home.packages =
          [ ]
          ++ (lib.optional osConfig.nether.graphicalEnv.extra.networkmanagerapplet.enable pkgs.networkmanagerapplet);
      };
    }
  );
}
