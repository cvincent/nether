{ name, mkSoftware, ... }:
mkSoftware name (
  {
    khal,
    nether,
    lib,
    ...
  }:
  {
    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };

      defaultCalendar = lib.mkOption {
        type = lib.types.str;
        description = "Khal dubiously expects this to be the display name.";
      };

      dbPath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.cache/khal/khal.db";
      };

      readOnlyCalendars = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };
    };

    nixos.nether.backups.paths.${khal.dbPath}.deleteMissing = true;

    hm = {
      accounts.calendar.accounts =
        (
          khal.accountConfigs
          |> builtins.mapAttrs (
            account: accountConfig: {
              khal = {
                enable = true;
                type = "discover";
                addresses = [ accountConfig.email ] ++ accountConfig.aliases;
                color = "#${accountConfig.color}";
              };
            }
          )
        )
        // (
          khal.readOnlyCalendars
          |> builtins.mapAttrs (
            name: config: {
              khal = {
                enable = true;
                type = "calendar";
                readOnly = true;
                color = "#${config.color}";
              };
            }
          )
        );

      programs.khal = {
        inherit (khal) enable package;

        settings = {
          default = {
            default_calendar = lib.mkForce khal.defaultCalendar;
            highlight_event_days = true;
          };

          sqlite.path = khal.dbPath;
        };

        locale = {
          dateformat = "%-m/%-d";
          longdateformat = "%-m/%-d/%Y";
          datetimeformat = "%-m/%-d %-I:%M%P";
          longdatetimeformat = "%-m/%-d/%Y %-I:%M%P";
          timeformat = "%-I:%M%P";
        };
      };
    };
  }
)
