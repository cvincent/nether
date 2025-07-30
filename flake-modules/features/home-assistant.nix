{ name, ... }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.homeAssistant.enable = lib.mkEnableOption "Home Assistant desktop integrations";

        nether.homeAssistant.notifier.enable = lib.mkOption {
          type = lib.types.bool;
          description = "Peroxide third-party bridge for ProtonMail";
          default = config.nether.homeAssistant.enable;
        };
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
