{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgInputs }:
    { config, ... }:
    {
      options = {
        nether.steam.enable = lib.mkEnableOption "Steam";
      };

      config = lib.mkIf config.nether.steam.enable {
        programs.steam.enable = true;
        programs.steam.package = pkgInputs.nixpkgs-unstable-latest.steam;
        environment.systemPackages = [
          pkgInputs.nixpkgs-unstable-latest.protonup-qt
          pkgInputs.nixpkgs-unstable-latest.protontricks
        ];
      };
    }
  );
}
