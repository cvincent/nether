{ name }:
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
      options.nether.ssh = (helpers.pkgOpt pkgs.ssh true "SSH client") // { };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {

      config = lib.mkIf osConfig.nether.ssh.enable {
        programs.ssh = {
          enable = true;
          package = osConfig.nether.ssh.package;
          extraConfig = lib.strings.concatLines [ inputs.private-nethers.ssh.extraConfig ];
        };

        home.file = inputs.private-nethers.ssh.keys;
      };
    };
}
