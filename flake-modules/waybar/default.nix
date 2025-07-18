{ name }:
{ lib, ... }:
{
  flake.homeModules."${name}" =
    { osConfig, helpers, ... }:
    let
      inherit (osConfig.nether.graphicalEnv) bar;
    in
    {
      config = lib.mkIf (bar.which == "waybar") {
        home.packages = [ bar.waybar.package ];
        home.file."./.config/waybar".source = helpers.directSymlink ./configs;
      };
    };
}
