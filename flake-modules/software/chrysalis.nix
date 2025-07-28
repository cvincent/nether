{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgInputs }:
    { config, ... }:
    {
      options = {
        nether.hardware.chrysalis.enable = lib.mkEnableOption "Chrysalis layout editor for Keyboardio";
      };

      config = lib.mkIf config.nether.hardware.chrysalis.enable {
        environment.systemPackages = [ pkgInputs.nixpkgs-unstable.chrysalis ];
        services.udev.packages = [ pkgInputs.nixpkgs-unstable.chrysalis ];
      };
    }
  );
}
