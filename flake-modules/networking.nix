{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.hostname = lib.mkOption { type = lib.types.str; };

        nether.networkmanager.enable = lib.mkEnableOption "NetworkManager";
        nether.firewall.enable = lib.mkEnableOption "Linux firewall";

        nether.tor.enable = lib.mkEnableOption "Tor";
      };

      config = {
        networking.hostName = config.nether.hostname;
        networking.networkmanager.enable = config.nether.networkmanager.enable;
        networking.firewall.enable = config.nether.firewall.enable;

        services.tor.client.enable = config.nether.tor.enable;

        users.users."${config.nether.username}" = lib.mkIf config.nether.networkmanager.enable {
          extraGroups = [ "networkmanager" ];
        };
      };
    };
}
