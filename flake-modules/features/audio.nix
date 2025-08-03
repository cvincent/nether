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
      blueman.defaultEnable = nether.graphicalEnv.enable && audio.bluetooth.enable;
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
      hardware.bluetooth.enable = audio.bluetooth.enable;
    };
  }
)
