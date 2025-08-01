{ name, ... }:
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
        nether.software."${name}" =
          helpers.pkgOpt pkgs.btop false
            "btop - nice-looking terminal-based system monitor";
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether.software) btop;
    in
    {
      programs.btop = {
        inherit (btop) enable package;
        settings.color_theme = lib.mkForce osConfig.nether.theme;
        settings.theme_background = false;
      };
    };
}
