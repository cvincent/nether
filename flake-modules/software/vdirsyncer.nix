{ name, mkSoftware, ... }:
mkSoftware name (
  {
    vdirsyncer,
    nether,
    lib,
    ...
  }:
  {
    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };

      readOnlyCalendars = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };

      statePath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.local/state/vdirsyncer";
      };

      statusPath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.local/share/vdirsyncer/status";
      };
    };

    nixos.nether.backups.paths = {
      ${vdirsyncer.statePath}.deleteMissing = true;
      ${vdirsyncer.statusPath}.deleteMissing = true;
    };

    hm = {
      accounts.calendar.accounts =
        (
          vdirsyncer.accountConfigs
          |> lib.filterAttrs (_: accountConfig: accountConfig.calendar.type == "google_calendar")
          |> builtins.mapAttrs (
            account: accountConfig: {
              remote.type = "google_calendar";

              vdirsyncer = {
                enable = true;

                clientIdCommand = [
                  "echo"
                  accountConfig.calendar.credentials.clientId
                ];

                clientSecretCommand = [
                  "echo"
                  accountConfig.calendar.credentials.clientSecret
                ];

                tokenFile = "${vdirsyncer.statePath}/${accountConfig.name}-token";
                collections = [ accountConfig.email ];
              };
            }
          )
        )
        // (
          vdirsyncer.readOnlyCalendars
          |> builtins.mapAttrs (
            name: config: {
              remote = {
                inherit (config) url;
                type = "http";
              };

              vdirsyncer = {
                enable = true;
                collections = [ ];
              };
            }
          )
        );

      accounts.contact.accounts =
        vdirsyncer.accountConfigs
        |> lib.filterAttrs (_: accountConfig: accountConfig.calendar.type == "icloud")
        |> builtins.mapAttrs (
          account: accountConfig: {
            remote = {
              type = "carddav";
              url = "https://contacts.icloud.com/";
              userName = accountConfig.calendar.credentials.username;
              passwordCommand = [
                "echo"
                accountConfig.calendar.credentials.password
              ];
            };

            vdirsyncer = {
              enable = true;
              collections = [ "card" ];
            };
          }
        );

      programs.vdirsyncer = {
        inherit (vdirsyncer) enable package;
      };

      services.vdirsyncer = {
        inherit (vdirsyncer) enable package;
        frequency = "*:*:0/15";
      };
    };
  }
)
