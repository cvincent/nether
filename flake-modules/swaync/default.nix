{ name }:
{ lib, ... }:
{
  flake.homeModules."${name}" =
    { osConfig, helpers, ... }:
    let
      inherit (osConfig.nether.graphicalEnv) notifications;
    in
    {
      config = lib.mkIf (notifications.which == "swaync") {
        home.packages = [ notifications.swaync.package ];
        home.file."./.config/swaync".source = helpers.directSymlink ./configs;
      };
    };
}
