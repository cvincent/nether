{ name }:
{
  lib,
  helpers,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options = {
        nether.backups = {
          enable = lib.mkEnableOption "System for automatically backing up select files to the network drive, and restoring them on activation";

          mount = {
            # TODO: Ensure references to /backup throughout the config refer to
            # this option
            path = lib.mkOption {
              type = lib.types.str;
              default = "/backup";
            };

            device = lib.mkOption {
              type = lib.types.str;
              default = "192.168.1.128:/storage/smb";
            };

            options = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [
                "nfsvers=4.2"
                "noatime"
                "nofail"
              ];
            };
          };
        };
      };

      config = lib.mkIf config.nether.backups.enable (
        {
          fileSystems."${backupMount}" = {
            device = config.nether.backups.mount.device;
            fsType = "nfs";
            options = config.nether.backups.mount.options;
          };
        }
      );
    }
  );
}
