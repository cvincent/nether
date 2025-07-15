{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.timezone = lib.mkOption {
          type = lib.types.str;
          default = "America/Chicago";
        };

        nether.locale = lib.mkOption {
          type = lib.types.str;
          default = "en_US.UTF-8";
        };

        nether.keyboard.layout = lib.mkOption {
          type = lib.types.str;
          default = "us";
        };

        nether.keyboard.variant = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
      };

      config = {
        time.timeZone = config.nether.timezone;
        i18n.defaultLocale = config.nether.locale;

        i18n.extraLocaleSettings = {
          LC_ADDRESS = config.nether.locale;
          LC_IDENTIFICATION = config.nether.locale;
          LC_MEASUREMENT = config.nether.locale;
          LC_MONETARY = config.nether.locale;
          LC_NAME = config.nether.locale;
          LC_NUMERIC = config.nether.locale;
          LC_PAPER = config.nether.locale;
          LC_TELEPHONE = config.nether.locale;
          LC_TIME = config.nether.locale;
        };

        services.xserver.xkb = config.nether.keyboard;
      };
    };
}
