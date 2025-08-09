{ name, mkFeature, ... }:
mkFeature name (
  { timeAndLocale, lib, ... }:
  {
    options = {
      timezone = lib.mkOption {
        type = lib.types.str;
        default = "America/Chicago";
      };

      locale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
      };

      keyboard.layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
      };

      keyboard.variant = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };

    nixos = {
      time.timeZone = timeAndLocale.timezone;
      i18n.defaultLocale = timeAndLocale.locale;

      i18n.extraLocaleSettings = {
        LC_ADDRESS = timeAndLocale.locale;
        LC_IDENTIFICATION = timeAndLocale.locale;
        LC_MEASUREMENT = timeAndLocale.locale;
        LC_MONETARY = timeAndLocale.locale;
        LC_NAME = timeAndLocale.locale;
        LC_NUMERIC = timeAndLocale.locale;
        LC_PAPER = timeAndLocale.locale;
        LC_TELEPHONE = timeAndLocale.locale;
        LC_TIME = timeAndLocale.locale;
      };

      services.xserver.xkb = timeAndLocale.keyboard;
    };
  }
)
