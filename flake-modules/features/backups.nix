{ name, mkFeature, ... }:
mkFeature name (
  # Allows defining specific files or directories to be regularly backed up to the
  # network backup drive. On activation and boot, enabled backup files are
  # restored from the network drive to the machine being activated. Each file can
  # define a `fallbackSource`, which is the hostname of the machine the file
  # should be restored from if it's not already backed up for the own machine's
  # hostname. Each file also has an `enable` option, so hosts can select which
  # files they want.
  # NOTE: Once we're configuring the backup server with NixOS, we need to make
  # sure sudoers has a line like:
  # synthesis ALL=NOPASSWD:/path/to/rsync
  {
    nether,
    backups,
    lib,
    pkgs,
    ...
  }:
  let
    backupMount = backups.mount.path;

    backupPath = lib.types.submodule {
      options = {
        enable = (lib.mkEnableOption "Enable this backup path") // {
          default = true;
        };
        # TODO: compressTransfer option, for large files. Will require
        # updating how we generate our backup script.
        # TODO: Look into an option for selectively enabling rsync's Time
        # Machine like feature
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
            ++ nether.hosts
          );
          default = backups.defaultFallbackSource;
        };
      };
    };
  in
  {
    description = "System for automatically backing up select files to the network drive, and restoring them on activation";

    options = {
      server = {
        addr = lib.mkOption {
          type = lib.types.str;
          default = "192.168.1.128";
        };
        root = lib.mkOption {
          type = lib.types.str;
          default = "/storage/smb";
        };
        username = lib.mkOption {
          type = lib.types.str;
          default = "synthesis";
        };
      };

      mount = {
        # TODO: Ensure references to /backup throughout the config refer to
        # this option
        path = lib.mkOption {
          type = lib.types.str;
          # TODO: Be civilized and move this to /mnt/backup
          default = "/backup";
        };

        device = lib.mkOption {
          type = lib.types.str;
          default = "${nether.backups.server.addr}:${nether.backups.server.root}";
        };

        options = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "nfsvers=4.2"
            "noatime"
            "nofail"
            "bg" # Retry mounting for a week on failure
            "_netdev"
          ];
        };
      };

      paths = lib.mkOption {
        type = lib.types.attrsOf backupPath;
        default = { };
      };

      defaultFallbackSource = lib.mkOption { type = lib.types.str; };
    };

    toplevel.rsync = { };

    nixos =
      let
        rsync = backups.rsync.package;

        rsyncOpts = lib.strings.concatStringsSep " " [
          "--progress"
          "-arR"
          "-e '${nether.ssh.package}/bin/ssh -i ${nether.homeDirectory}/.ssh/id_rsa"
          "-o UserKnownHostsFile=${nether.homeDirectory}/.ssh/known_host_backup'"
          "--rsync-path='sudo rsync'"
        ];

        rsyncRemoteRoot = "${backups.server.username}@${backups.mount.device}";

        enabledPaths = lib.attrsets.filterAttrs (_: { enable, ... }: enable) backups.paths;

        restoreScripts = lib.attrsets.mapAttrsToList (
          path: opts:
          let
            hostPath = "${backupMount}/${nether.networking.hostname}";
            fallbackHostPath = "${backupMount}/${opts.fallbackSource}";
            remoteHostPath = "${rsyncRemoteRoot}/${nether.networking.hostname}";
            remoteFallbackHostPath = "${rsyncRemoteRoot}/${opts.fallbackSource}";
          in
          ''
            if [[ ! -e ${path} ]]; then
              if [[ -e ${hostPath}${path} ]]; then
                hostPath=${remoteHostPath}
              elif [[ -e ${fallbackHostPath}${path} ]]; then
                hostPath=${remoteFallbackHostPath}
              else
                hostPath=""
                echo "No source for ${path}"
              fi
              if [[ $hostPath ]]; then
                ${rsync}/bin/rsync ${rsyncOpts} --usermap=root:root,*:${nether.username} --groupmap=root:root,*:users "$hostPath/.${path}" /
              fi
            fi
          ''
        ) enabledPaths;

        restoreScript = pkgs.writeShellScriptBin "restore-all" (
          lib.strings.concatLines (
            [
              ''
                echo "Waiting for SSH key..."
                while ! ${pkgs.coreutils}/bin/test -f ${nether.homeDirectory}/.ssh/id_rsa; do
                  sleep 0.1
                done
              ''
            ]
            ++ restoreScripts
          )
        );

        backupWithoutDeletePaths =
          enabledPaths
          |> lib.attrsets.filterAttrs (_: { deleteMissing, ... }: !deleteMissing)
          |> lib.attrsets.mapAttrsToList (path: _opts: path);

        backupWithDeletePaths =
          enabledPaths
          |> lib.attrsets.filterAttrs (_: { deleteMissing, ... }: deleteMissing)
          |> lib.attrsets.mapAttrsToList (path: _opts: path);

        backupScript = pkgs.writeShellScriptBin "backup-all" ''
          ${rsync}/bin/rsync --progress ${rsyncOpts} -arR --files-from=/etc/backup/without-delete / ${rsyncRemoteRoot}/${nether.networking.hostname}
          ${rsync}/bin/rsync --progress ${rsyncOpts} -arR --delete --files-from=/etc/backup/with-delete / ${rsyncRemoteRoot}/${nether.networking.hostname}
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

        nether.ssh.enable = true;

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
              Options = backups.mount.options;
            };
            what = backups.mount.device;
            where = backups.mount.path;
            wantedBy = [ "remote-fs.target" ];
            before = [ "remote-fs.target" ];
          }
        ];

        # Backup is always called after successful restore-backups.service.
        # This means if we add new backup paths to our config, activating
        # the config will restore the new paths if they exist on remote,
        # then back up whatever we have in local. Which should be what we
        # want in every case.
        # TODO: On the backup server, once we're on NixOS there, do nightly
        # backups of each host or something similar that aren't written to, in
        # case something silly happens.
        system.userActivationScripts.restore-and-backup = ''
          ${pkgs.systemd}/bin/systemctl start restore-backups.service
        '';

        systemd.services.restore-backups = {
          wantedBy = [ "graphical-session.target" ];
          after = [ "graphical-session.target" ];
          description = "Restore enabled backup files if not present";
          unitConfig.RequiresMountsFor = backupMount;
          onSuccess = [ "backup-all.service" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${restoreScript}/bin/restore-all";
            TimeoutStopSec = "infinity";
            KillSignal = "SIGCONT";
          };
        };

        environment.etc."backup/without-delete".text = lib.strings.concatLines backupWithoutDeletePaths;
        environment.etc."backup/with-delete".text = lib.strings.concatLines backupWithDeletePaths;

        # TODO: Some mechanism that prevents this from running if
        # restore-backups.service is running, and vice-versa
        systemd.services.backup-all = {
          description = "Backup enabled backup files";
          after = [ "restore-backups.service" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${backupScript}/bin/backup-all";
            TimeoutStopSec = "infinity";
            KillSignal = "SIGCONT";
          };
        };

        systemd.timers.backup-all = {
          wantedBy = [ "timers.target" ];
          requires = [ "restore-backups.service" ];
          after = [ "restore-backups.service" ];
          timerConfig = {
            OnCalendar = "*-*-* 02:00:00";
            AccuracySec = "1s";
            Unit = "backup-all.service";
          };
        };
      };
  }
)
