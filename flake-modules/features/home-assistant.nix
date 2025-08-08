{ name, ... }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.homeAssistant.enable = lib.mkEnableOption "Home Assistant desktop integrations";
      };
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.homeAssistant.enable {
        services.ha-notifier.enable = osConfig.nether.homeAssistant.notifier.enable;
      };
    };
}
