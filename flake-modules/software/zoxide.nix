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
      inherit (config.nether.software) zoxide;
    in
    {
      options = {
        nether.software."${name}" =
          (helpers.pkgOpt pkgs.zoxide false "zoxide - a smarter cd that learns from your habits")
          // {
            enableFishIntegration = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
      };

      config = lib.mkIf zoxide.enable {
        nether.shells.aliases.cd = "z";
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether.software) zoxide;
    in
    {
      programs.zoxide = {
        inherit (zoxide) enable package enableFishIntegration;
      };
    };
}
