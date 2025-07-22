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
