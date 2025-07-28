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
    { ... }:
    {
      options = {
        nether.software."${name}" = (helpers.pkgOpt pkgs.eza false "eza - a modern replacement for ls") // {
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
      inherit (osConfig.nether.software) eza;
    in
    {
      programs.eza = {
        inherit (eza) enable package enableFishIntegration;
        git = true;
        extraOptions = [ "--group-directories-first" ];
      };

      programs.fish.shellAliases = lib.mkIf eza.enableFishIntegration {
        # Slight difference from aliases provided by the HM module
        l = "eza -l";
        ll = "eza -la";
      };
    };
}
