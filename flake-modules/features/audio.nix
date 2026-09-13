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

        extraConfig.pipewire."10-loopback-sink" = {
          "context.modules" = [
            {
              name = "libpipewire-module-loopback";
              args = {
                "node.description" = "Loopback Sink";
                "node.name" = "loopback-sink";
                "capture.props" = {
                  "media.class" = "Audio/Sink";
                  "audio.position" = "FL,FR";
                };
                "playback.props" = {
                  "node.name" = "loopback-sink.output";
                  "audio.position" = "FL,FR";
                  "target.object" = "default";
                  "node.passive" = true;
                };
              };
            }
          ];
        };
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
