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
    {
      options = {
        nether.software."${name}" = (
          helpers.pkgOpt pkgs.ripgrep false "ripgrep - very fast file contents search"
          // {
            enableFishIntegration = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          }
        );
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether.software) ripgrep;
    in
    {
      programs.ripgrep = {
        inherit (ripgrep) enable package;
        arguments = [ "--glob=!*.enc" ];
      };

      programs.fish.shellAliases = lib.mkIf ripgrep.enableFishIntegration {
        grep = "rg";
      };
    };
}
