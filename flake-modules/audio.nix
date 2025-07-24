{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    let
      inherit (config.nether) graphicalEnv hardware;
    in
    {
      options = {
        nether.hardware.audio = {
          enable = lib.mkEnableOption "Audio";

          rtkit.enable = helpers.boolOpt true "RealTime Kit";
          bluetooth.enable = helpers.boolOpt true "Bluetooth connectivity";

          apps = {
            alsaUtils = helpers.pkgOpt pkgs.alsa-utils true "ALSA utilities";

            blueman.enable = helpers.boolOpt (
              graphicalEnv.enable && hardware.audio.bluetooth.enable
            ) "Blueman - Bluetooth manager";

            pavucontrol = helpers.pkgOpt pkgs.pavucontrol true "PulseAudio Volume Control";
          };
        };
      };

      config = lib.mkIf config.nether.hardware.audio.enable {
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        security.rtkit.enable = hardware.audio.rtkit.enable;
        hardware.bluetooth.enable = hardware.audio.bluetooth.enable;

        services.blueman.enable = hardware.audio.apps.blueman.enable;
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether.hardware) audio;
    in
    {
      home.packages =
        [ ]
        ++ (lib.optional audio.apps.pavucontrol.enable audio.apps.pavucontrol.package)
        ++ (lib.optional audio.apps.alsaUtils.enable audio.apps.alsaUtils.package);
    };
}
