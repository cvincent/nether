{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      config = lib.mkIf (config.nether.graphicalEnv.screenLocker == "swaylock") {
        # NOTE: We should eventually not need this line here, see
        # https://github.com/NixOS/nixpkgs/issues/158025
        security.pam.services = {
          swaylock = { };
        };
      };
    };

  flake.homeModules."${name}" =
    { osConfig, helpers, ... }:
    let
      inherit (osConfig.nether.graphicalEnv) screenLocker;
    in
    {
      config = lib.mkIf (screenLocker.which == "swaylock") {
        home.packages = [ screenLocker.swaylock.package ];
        home.file."./.config/swaylock/config".source = helpers.directSymlink ./swaylock.conf;
      };
    };
}
