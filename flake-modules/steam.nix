{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { inputs' }:
    { config, ... }:
    {
      options = {
        nether.steam.enable = lib.mkEnableOption "Steam";
      };

      config = lib.mkIf config.nether.steam.enable {
        programs.steam.enable = true;
        environment.systemPackages = [
          inputs'.nixpkgs-unstable-latest.legacyPackages.protonup-qt
          inputs'.nixpkgs-unstable-latest.legacyPackages.protontricks
        ];
      };
    }
  );
}
