{ name, mkFeature, ... }:
mkFeature name (
  { homeAssistant, lib, ... }:
  {
    options.notifier.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Peroxide third-party bridge for ProtonMail";
      default = true;
    };

    hm.services.ha-notifier.enable = homeAssistant.notifier.enable;
  }
)
