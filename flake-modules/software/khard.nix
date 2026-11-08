{ name, mkSoftware, ... }:
mkSoftware name (
  { khard, lib, ... }:
  {
    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };
    };

    hm = {
      accounts.contact.accounts =
        khard.accountConfigs
        |> lib.filterAttrs (_: accountConfig: accountConfig.calendar.type == "icloud")
        |> builtins.mapAttrs (
          _: _: {
            khard = {
              enable = true;
              addressbooks = [ "card" ];
            };
          }
        );

      programs.khard = {
        inherit (khard) enable package;
      };
    };
  }
)
