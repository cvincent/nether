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
    {
      options = {
        nether.software."${name}" = (helpers.pkgOpt pkgs.bat false "bat - cat clone with wings") // {
          enableFishIntegration = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether.software) bat;
    in
    {
      programs.bat = { inherit (bat) enable package; };

      programs.fish.shellAliases = lib.mkIf bat.enableFishIntegration {
        cat = "bat";
      };
    };
}
