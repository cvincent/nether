{ name }:
{
  lib,
  helpers,
  moduleWithSystem,
  ...
}:
# Allows defining specific files or directories to be regularly backed up to the
# network backup drive. On activation, enabled backup files are copied from the
# network drive to the machine being activated. Each file can define a `source`,
# which is the hostname of the machine the file should be backed up from. If
# null, the machine's own hostname is used. Each file also has an `enable`
# option, so hosts can select which files they want.
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    let
      backupMount = config.nether.backups.mount.path;

      backupPath = lib.types.submodule {
        options = {
          enable = (lib.mkEnableOption "Enable this backup path") // {
            default = true;
          };
          owner = lib.mkOption {
            type = lib.types.str;
            default = config.nether.username;
          };
          group = lib.mkOption {
            type = lib.types.str;
            default = "users";
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "600";
          };
          source = lib.mkOption {
            type = lib.types.enum ([ null ] ++ config.nether.hosts);
            default = config.nether.backups.defaultSource;
          };
        };
      };
    in
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

          paths = lib.mkOption {
            type = lib.types.attrsOf backupPath;
            default = { };
          };

          defaultSource = lib.mkOption { type = lib.types.str; };

          rsync = helpers.pkgOpt pkgs.rsync true "rsync - robust copying for backups";
        };
      };

      config = lib.mkIf config.nether.backups.enable (
        let
          enabledPaths = lib.attrsets.filterAttrs (_: { enable, ... }: enable) config.nether.backups.paths;
          backupPaths = lib.attrsets.filterAttrs (
            _: { source, ... }: builtins.elem source ([ null ] ++ config.nether.networking.hostname)
          ) enabledPaths;
        in
        {
          environment.systemPackages = [ config.nether.backups.rsync.package ];

          fileSystems."${backupMount}" = {
            device = config.nether.backups.mount.device;
            fsType = "nfs";
            options = config.nether.backups.mount.options;
          };

          systemd.services = lib.attrsets.mapAttrs' (
            path: opts:
            let
              sourcePath =
                if opts.source != null then
                  "${backupMount}/${opts.source}"
                else
                  "${backupMount}/${config.nether.networking.hostname}";

              restore = pkgs.writeShellScript "restore" ''
                if [[ ! -e ${path} ]]; then
                  dir=$(dirname ${backupMount}/${sourcePath}${path})
                  mkdir -p ''${dir#"${sourcePath}"}
                  cp -R ${sourcePath}${path} ${path}
                  chown ${opts.owner}:${opts.group} ${path}
                  chmod ${opts.mode} ${path}
                fi
              '';
            in
            {
              name = "backups-${lib.strings.replaceStrings [ "/" "." ] [ "-" "-" ] path}";
              value = {
                wantedBy = [ "multi-user.target" ];
                description = "Backup system - restore ${path}";
                requires = [ "remote-fs.target" ];
                after = [ "remote-fs.target" ];
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = restore;
                };
              };
            }
          ) enabledPaths;
        }
      );
    }
  );
}
