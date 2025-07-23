{ name }:
{
  lib,
  inputs,
  moduleWithSystem,
  ...
}:
{
  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, helpers, ... }:
    {
      options.nether.git = helpers.pkgOpt pkgs.git true "Git SCM";

      config = lib.mkIf osConfig.nether.git.enable {
        programs.git = {
          enable = true;
          userName = osConfig.nether.me.fullName;
          email = osConfig.nether.me.email;

          ignores = [ "Session.vim" ];

          extraConfig = lib.attrsets.recursiveUpdate {
            init.defaultBranch = "main";
          } inputs.private-nethers.git.extraConfig;
        };
      };
    }
  );
}
