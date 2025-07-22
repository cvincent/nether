{ name }:
{ lib, inputs, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.username = lib.mkOption { type = lib.types.str; };
        nether.me.fullName = lib.mkOption { type = lib.types.str; };
        nether.me.email = lib.mkOption { type = lib.types.str; };
      };

      config = {
        users.users."${config.nether.username}" = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };

        nether.me.fullName = "Chris Vincent";
        nether.me.email = inputs.private-nethers.email;
      };
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      home.username = osConfig.nether.username;
      home.homeDirectory = "/home/${osConfig.nether.username}";
    };
}
