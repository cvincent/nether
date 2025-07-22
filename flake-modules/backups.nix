{ name }:
{
  lib,
  helpers,
  moduleWithSystem,
  ...
}:
# Allows defining specific files or directories to be regularly backed up to the
# network backup drive. On activation and boot, enabled backup files are
# restored from the network drive to the machine being activated. Each file can
# define a `fallbackSource`, which is the hostname of the machine the file
# should be restored from if it's not already backed up for the own machine's
# hostname. Each file also has an `enable` option, so hosts can select which
# files they want.
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
          deleteMissing = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          fallbackSource = lib.mkOption {
            type = lib.types.enum (
              [
                null
                "test-host"
              ]
              ++ config.nether.hosts
            );
            default = config.nether.backups.defaultFallbackSource;
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
                "bg" # Retry mounting for a week on failure
              ];
            };
          };

          paths = lib.mkOption {
            type = lib.types.attrsOf backupPath;
            default = { };
          };

          defaultFallbackSource = lib.mkOption { type = lib.types.str; };

          rsync = helpers.pkgOpt pkgs.rsync true "rsync - robust copying for backups";
        };
      };

      config = lib.mkIf config.nether.backups.enable (
        let
          rsync = config.nether.backups.rsync.package;

          enabledPaths = lib.attrsets.filterAttrs (_: { enable, ... }: enable) config.nether.backups.paths;

          restoreScripts = lib.attrsets.mapAttrsToList (
            path: opts:
            let
              hostPath = "${backupMount}/${config.nether.networking.hostname}";
              fallbackHostPath = "${backupMount}/${opts.fallbackSource}";
            in
            ''
              if [[ ! -e ${path} ]]; then
                if [[ -e ${hostPath}${path} ]]; then
                  hostPath=${hostPath}
                elif [[ -e ${fallbackHostPath}${path} ]]; then
                  hostPath=${fallbackHostPath}
                else
                  echo "No source for ${path}"
                fi
                if [[ -d $hostPath ]]; then
                  ${rsync}/bin/rsync -arR --usermap=root:root,*:${config.nether.username} --groupmap=root:root,*:users "$hostPath/.${path}" /
                fi
              fi
            ''
          ) enabledPaths;

          restoreScript = pkgs.writeShellScriptBin "restore-all" (lib.strings.concatLines restoreScripts);

          backupWithoutDeletePaths =
            enabledPaths
            |> lib.attrsets.filterAttrs (_: { deleteMissing, ... }: !deleteMissing)
            |> lib.attrsets.mapAttrsToList (path: _opts: path);

          backupWithDeletePaths =
            enabledPaths
            |> lib.attrsets.filterAttrs (_: { deleteMissing, ... }: deleteMissing)
            |> lib.attrsets.mapAttrsToList (path: _opts: path);

          backupScript = pkgs.writeShellScriptBin "backup-all" ''
            ${rsync}/bin/rsync -ar --files-from=/etc/backup/without-delete / /backup/${config.nether.networking.hostname}
            ${rsync}/bin/rsync -ar --delete --files-from=/etc/backup/with-delete / /backup/${config.nether.networking.hostname}
          '';
        in
        {
          # nether.backups.paths."/home/cvincent/arbitrary/test-file" = {
          #   fallbackSource = "test-host";
          # };
          # nether.backups.paths."/home/cvincent/arbitrary-dir" = {
          #   fallbackSource = "test-host";
          # };
          # nether.backups.paths."/home/cvincent/arbitrary-dir-with-delete" = {
          #   deleteMissing = true;
          # };

          environment.systemPackages = [
            rsync
            restoreScript
            backupScript
          ];

          boot.supportedFilesystems = [ "nfs" ];

          systemd.mounts = [
            {
              type = "nfs";
              mountConfig = {
                Options = config.nether.backups.mount.options;
              };
              what = config.nether.backups.mount.device;
              where = config.nether.backups.mount.path;
              wantedBy = [ "remote-fs.target" ];
              before = [ "remote-fs.target" ];
            }
          ];

          system.activationScripts.restore-and-backup = ''
            ${restoreScript}/bin/restore-all
            ${backupScript}/bin/backup-all
          '';

          systemd.services.restore-backups = {
            wantedBy = [ "multi-user.target" ];
            description = "Restore enabled backup files if not present";
            wants = [ "remote-fs.target" ];
            after = [ "remote-fs.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${restoreScript}/bin/restore-all";
            };
          };

          environment.etc."backup/without-delete".text = lib.strings.concatLines backupWithoutDeletePaths;
          environment.etc."backup/with-delete".text = lib.strings.concatLines backupWithDeletePaths;

          systemd.services.backup-all = {
            description = "Backup enabled backup files";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${backupScript}/bin/backup-all";
            };
          };

          systemd.timers.backup-all = {
            wantedBy = [ "timers.target" ];
            requires = [ "restore-backups.service" ];
            after = [ "restore-backups.service" ];
            timerConfig = {
              OnActiveSec = "0s";
              OnUnitActiveSec = "5m";
              AccuracySec = "1s";
              Unit = "backup-all.service";
            };
          };
        }
      );
    }
  );
}
