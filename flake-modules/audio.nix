{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.hardware.audio.enable = lib.mkEnableOption "Audio";
      };

      config = lib.mkIf config.nether.hardware.audio.enable {
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        hardware.bluetooth.enable = true;
        services.blueman.enable = true;
      };
    };
}
