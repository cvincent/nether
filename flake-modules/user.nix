{ lib, ... }:
{
  flake.nixosModules.user =
    { config, ... }:
    {
      options = {
        nether.username = lib.mkOption { type = lib.types.str; };
      };

      config = {
        users.users."${config.nether.username}" = {
          isNormalUser = true;
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
        };
      };
    };
}
