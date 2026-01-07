{ name, mkSoftware, ... }:
mkSoftware name (
  {
    flameshot,
    pkgs,
    config,
    ...
  }:
  {
    package = (pkgs.flameshot.override { enableWlrSupport = true; });

    hm.services.flameshot = {
      inherit (flameshot) enable package;

      settings.General = {
        contrastOpacity = 191;
        disabledTrayIcon = true;
        showDesktopNotification = false;
        showStartupLaunchMessage = false;
        useGrimAdapter = true;

        uiColor = "#${config.lib.stylix.colors.base00}";
        contrastUiColor = "#${config.lib.stylix.colors.base05}";
      };
    };
  }
)
