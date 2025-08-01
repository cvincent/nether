{ name, ... }:
{ lib, ... }:
{
  flake.homeModules."${name}" =
    { osConfig, helpers, ... }:
    let
      inherit (osConfig.nether) graphicalEnv;
    in
    {
      config = lib.mkIf (graphicalEnv.enable && graphicalEnv.bar.which == "waybar") {
        home.packages = [ graphicalEnv.bar.waybar.package ];
        home.file."./.config/waybar".source = helpers.directSymlink ./configs;
      };
    };
}
