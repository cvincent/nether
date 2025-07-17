{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options.nether.networking = {
        hostname = lib.mkOption { type = lib.types.str; };

        networkmanager.enable = lib.mkEnableOption "NetworkManager";
        firewall.enable = lib.mkEnableOption "Linux firewall";
        openssh.enable = lib.mkEnableOption "OpenSSH";
        tor.enable = lib.mkEnableOption "Tor";

        extra.networkmanagerapplet.enable = lib.mkOption {
          type = lib.types.bool;
          default = config.nether.networking.networkmanager.enable && config.nether.graphicalEnv.enable;
        };
      };

      config = {
        networking.hostName = config.nether.networking.hostname;

        networking.networkmanager.enable = config.nether.networking.networkmanager.enable;
        networking.firewall.enable = config.nether.networking.firewall.enable;
        services.openssh.enable = config.nether.networking.openssh.enable;
        services.tor.client.enable = config.nether.networking.tor.enable;

        users.users."${config.nether.username}" = lib.mkIf config.nether.networking.networkmanager.enable {
          extraGroups = [ "networkmanager" ];
        };
      };
    };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      home.packages = lib.optional osConfig.nether.networking.extra.networkmanagerapplet.enable pkgs.networkmanagerapplet;
    }
  );
}
