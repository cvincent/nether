{ name }:
{ lib, ... }:
{
  flake.homeModules."${name}" =
    { osConfig, helpers }:
    let
      inherit (osConfig.nether.graphicalEnv) notifications;
    in
    {
      home.packages = lib.optional (notifications == "swaync") notifications.swaync.package;
      home.file."./.config/swaync".source = helpers.directSymlink ./configs;
    };
}
