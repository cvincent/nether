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
      inherit (config.nether.software) eza;
    in
    {
      options = {
        nether.software."${name}" = (helpers.pkgOpt pkgs.eza false "eza - a modern replacement for ls") // {
          enableFishIntegration = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };

      config = lib.mkIf eza.enable {
        nether.shells.aliases = {
          # Slight difference from aliases provided by the HM module
          l = "eza -l";
          ll = "eza -la";
        };
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether.software) eza;
    in
    {
      programs.eza = {
        inherit (eza) enable package enableFishIntegration;
        git = true;
        extraOptions = [ "--group-directories-first" ];
      };
    };
}
