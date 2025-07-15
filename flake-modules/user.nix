{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.username = lib.mkOption { type = lib.types.str; };
      };

      config = {
        users.users."${config.nether.username}" = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };
      };
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      home.username = osConfig.nether.username;
      home.homeDirectory = "/home/${osConfig.nether.username}";
    };
}
