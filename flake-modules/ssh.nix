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
    let
      sshKeys = lib.attrsets.mapAttrs' (
        name: opts:
        let
          path = "${osConfig.nether.homeDirectory}/${name}";
        in
        {
          name = "${name}-dummy";
          value = opts // {
            onChange = ''
              rm -f ${path}
              cp ${path}-dummy ${path}
              rm -f ${path}-dummy
              chmod 600 ${path}
            '';
          };
        }
      ) inputs.private-nethers.ssh.keys;
    in
    {
      config = lib.mkIf osConfig.nether.ssh.enable {
        programs.ssh = {
          enable = true;
          package = osConfig.nether.ssh.package;
          extraConfig = lib.strings.concatLines [ inputs.private-nethers.ssh.extraConfig ];
        };

        home.file = sshKeys // {
          ".ssh/known_host_backup".text = inputs.private-nethers.ssh.knownHostBackup;
        };
      };
    };
}
