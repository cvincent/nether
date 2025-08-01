{ name, ... }:
{
  lib,
  inputs,
  moduleWithSystem,
  helpers,
  ...
}:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { ... }:
    {
      options.nether.git = helpers.pkgOpt pkgs.git true "Git SCM";
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {

      config = lib.mkIf osConfig.nether.git.enable {
        programs.git = {
          enable = true;
          package = osConfig.nether.git.package;

          userName = osConfig.nether.me.fullName;
          userEmail = osConfig.nether.me.email;

          ignores = [ "Session.vim" ];

          extraConfig = lib.attrsets.recursiveUpdate {
            init.defaultBranch = "main";
          } inputs.private-nethers.git.extraConfig;
        };
      };
    };
}
