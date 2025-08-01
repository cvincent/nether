{ name, ... }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = {
    options.nether.smartCalcTUI.enable = lib.mkEnableOption "SmartCalc TUI for various calculation needs";
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { self', pkgs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.smartCalcTUI.enable {
        home.packages = [
          self'.packages.smartcalc-tui
          (pkgs.writeShellScriptBin "smartcalc-slow-start" ''
            sleep 1
            smartcalc
          '')
        ];
      };
    }
  );
}
