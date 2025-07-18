{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
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

          compositor = lib.mkOption {
            type = lib.types.enum [
              null
              "hyprland"
            ];
            default = null;
          };

          extra = {
            gnomeKeyring.enable = helpers.boolOpt true "GNOME Keyring - some apps need this to store secrets";
            libnotify.enable = helpers.boolOpt true "libnotify - utilities for system notifications";
          };
        };
      };

      config = lib.mkIf config.nether.graphicalEnv.enable {
        services.xserver = {
          enable = true;
          displayManager.gdm.enable = config.nether.graphicalEnv.displayManager == "gdm";
        };

        security.pam.services.login.enableGnomeKeyring =
          config.nether.graphicalEnv.extra.gnomeKeyring.enable;
        services.gnome.gnome-keyring.enable = config.nether.graphicalEnv.extra.gnomeKeyring.enable;
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    let
      inherit (osConfig.nether) graphicalEnv;
    in
    {
      config = lib.mkIf graphicalEnv.enable {
        home.packages = lib.optional graphicalEnv.extra.libnotify.enable pkgs.libnotify;
      };
    }
  );
}
