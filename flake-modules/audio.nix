{ name }:
{ lib, moduleWithSystem, ... }:
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

          rtkit.enable = lib.mkOption {
            type = lib.types.bool;
            description = "RealTime Kit";
            default = true;
          };

          bluetooth.enable = lib.mkOption {
            type = lib.types.bool;
            description = "Bluetooth connectivity";
            default = true;
          };

          extra = {
            blueman.enable = lib.mkOption {
              type = lib.types.bool;
              description = "Blueman - Bluetooth manager";
              default = graphicalEnv.enable && hardware.audio.bluetooth.enable;
            };

            pavucontrol = {
              enable = lib.mkOption {
                type = lib.types.bool;
                description = "PulseAudio Volume Control";
                default = graphicalEnv.enable && hardware.audio.bluetooth.enable;
              };

              package = lib.mkOption {
                type = lib.types.package;
                default = pkgs.pavucontrol;
              };
            };
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

        services.blueman.enable = hardware.audio.extra.blueman.enable;
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
        [ ] ++ (lib.optional audio.extra.pavucontrol.enable audio.extra.pavucontrol.package);
    };
}
