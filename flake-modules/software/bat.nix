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
      inherit (config.nether.software) bat;
    in
    {
      options = {
        nether.software."${name}" = (helpers.pkgOpt pkgs.bat false "bat - cat clone with wings");
      };

      config = lib.mkIf bat.enable {
        nether.shells.aliases.cat = "bat";
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
    };
}
