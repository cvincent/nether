{ name }:
{ lib, ... }:
{
  flake.homeModules."${name}" =
    { osConfig, helpers, ... }:
    let
      inherit (osConfig.nether) graphicalEnv;
    in
    {
      config = lib.mkIf (graphicalEnv.enable && graphicalEnv.notifications.which == "swaync") {
        home.packages = [ graphicalEnv.notifications.swaync.package ];
        home.file."./.config/swaync".source = helpers.directSymlink ./configs;
      };
    };
}
