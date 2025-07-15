{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.system.stateVersion = lib.mkOption { type = lib.types.str; };
        nether.home.stateVersion = lib.mkOption { type = lib.types.str; };
      };

      config = {
        system.stateVersion = config.nether.system.stateVersion;
      };
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      home.stateVersion = osConfig.nether.home.stateVersion;
    };
}
