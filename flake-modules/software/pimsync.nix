{ name, mkSoftware, ... }:
mkSoftware name (
  {
    pimsync,
    nether,
    lib,
    ...
  }:
  {
    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };

      statusPath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.local/share/pimsync/status";
      };
    };

    nixos.nether.backups.paths.${pimsync.statusPath}.deleteMissing = true;

    hm = {
      accounts.calendar.accounts = (
        pimsync.accountConfigs
        |> lib.filterAttrs (_: accountConfig: accountConfig.calendar.type == "icloud")
        |> builtins.mapAttrs (
          account: accountConfig: {
            remote = {
              type = "caldav";
              url = "https://caldav.icloud.com/";
              userName = accountConfig.calendar.credentials.username;
              passwordCommand = [
                "echo"
                accountConfig.calendar.credentials.password
              ];
            };

            pimsync = {
              enable = true;

              extraRemoteStorageDirectives = [
                {
                  name = "interval";
                  params = [ 15 ];
                }
              ];

              extraPairDirectives =
                accountConfig.calendar.collections
                |> map (collection: {
                  name = "collection";
                  params = [ collection ];
                });
            };
          }
        )
      );

      programs.pimsync = {
        inherit (pimsync) enable package;

        settings = [
          {
            name = "status_path";
            params = [ pimsync.statusPath ];
          }
        ];
      };

      services.pimsync = {
        inherit (pimsync) enable package;
      };
    };
  }
)
