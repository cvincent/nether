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
    { config, ... }:
    {
      options.nether.ssh = (helpers.pkgOpt pkgs.openssh true "SSH client") // { };

      config = lib.mkIf config.nether.ssh.enable {
        nether.backups.paths."${config.nether.homeDirectory}/.ssh/known_hosts" = { };
      };
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
