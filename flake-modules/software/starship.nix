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
    { ... }:
    {
      options = {
        nether.software."${name}" =
          (helpers.pkgOpt pkgs.starship false "starship - a nice shell prompt")
          // {
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
      inherit (osConfig.nether.software) starship;
    in
    {
      programs.starship = {
        inherit (starship) enable package enableFishIntegration;
      };
    };
}
