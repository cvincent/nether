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
        nether.software."${name}" = (helpers.pkgOpt pkgs.fzf false "fzf - a command-line fuzzy finder") // {
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
      inherit (osConfig.nether.software) fzf;
    in
    {
      config = lib.mkIf fzf.enable {
        programs.fzf = {
          inherit (fzf) enable package;
          defaultOptions = [ "--bind=ctrl-h:backward-kill-word" ];
          colors.bg = lib.mkForce "-1";
        };
      };
    };
}
