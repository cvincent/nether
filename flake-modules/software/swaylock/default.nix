{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    let
      inherit (config.nether) graphicalEnv;
    in
    {
      config = lib.mkIf (graphicalEnv.enable && graphicalEnv.screenLocker == "swaylock") {
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
      inherit (osConfig.nether) graphicalEnv;
    in
    {
      config = lib.mkIf (graphicalEnv.enable && graphicalEnv.screenLocker.which == "swaylock") {
        home.packages = [ graphicalEnv.screenLocker.swaylock.package ];
        home.file."./.config/swaylock/config".source = helpers.directSymlink ./swaylock.conf;
      };
    };
}
