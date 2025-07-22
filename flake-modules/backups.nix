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
                else
                  if [[ -e ${fallbackHostPath}${path} ]]; then
                    hostPath=${fallbackHostPath}
                  else
                    echo "Could not find source for ${path}"
                    exit 0
                  fi
                fi
                dir=$(dirname "$hostPath${path}")
                mkdir -p ''${dir#"$hostPath"}
                cp -R "$hostPath${path}" ${path}
                chown ${opts.owner}:${opts.group} ${path}
                chmod ${opts.mode} ${path}
              fi
            ''
          ) enabledPaths;

          restoreScript = pkgs.writeShellScript "restore" (lib.strings.concatLines restoreScripts);

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

          systemd.services.restore-backups = {
            wantedBy = [ "multi-user.target" ];
            description = "Restore enabled backup files if not present";
            requires = [ "remote-fs.target" ];
            after = [ "remote-fs.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = restoreScript;
            };
          };
        }
      );
    }
  );
}
