{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options = {
        nether.ios.enable = lib.mkEnableOption "iOS interfacing";
      };

      config = lib.mkIf config.nether.ios.enable {
        environment.systemPackages = with pkgs; [
          libimobiledevice
          ifuse
        ];

        services.usbmuxd = {
          enable = true;
          package = pkgs.usbmuxd2;
        };
      };
    }
  );
}
