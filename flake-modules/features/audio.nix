{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    audio,
    helpers,
    ...
  }:
  {
    description = "Make some noise";

    options = {
      rtkit.enable = helpers.boolOpt true "RealTime Kit";
      bluetooth.enable = helpers.boolOpt true "Bluetooth connectivity";
    };

    apps = {
      alsa-utils = { };

      blueman = {
        defaultEnable = nether.graphicalEnv.enable && audio.bluetooth.enable;
        config.trayService.enable = true;
      };

      pavucontrol = { };
    };

    nixos = {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      security.rtkit.enable = audio.rtkit.enable;

      hardware.bluetooth = {
        enable = audio.bluetooth.enable;

        # Attempt to connect using A2DP
        # settings.General = {
        #   Enable = "Source,Sink,Media,Socket";
        # };
      };
    };
  }
)
