{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    homeAssistant,
    lib,
    ...
  }:
  {
    description = "Home Assistant integrations";

    options.notifier.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Daemon for receiving notifications from Home Assistant";
      default = true;
    };

    hm.services.ha-notifier = {
      enable = homeAssistant.notifier.enable;
      libnotify = nether.graphicalEnv.notifications.libnotify.package;
    };
  }
)
