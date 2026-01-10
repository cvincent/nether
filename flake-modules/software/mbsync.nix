{ name, mkSoftware, ... }:
mkSoftware name (
  {
    mbsync,
    lib,
    pkgs,
    ...
  }:
  {
    package = pkgs.isync;

    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };
    };

    hm = {
      accounts.email.accounts =
        mbsync.accountConfigs
        |> builtins.mapAttrs (
          account: accountConfig: {
            mbsync = {
              enable = true;

              create = "both";
              expunge = "both";

              patterns = [ "*" ] ++ (accountConfig.excludeFolders |> map (f: "!${f}"));

              extraConfig = {
                account.Timeout = 0;
                remote.PathDelimiter = "/";
              };
            };
          }
        );

      programs.mbsync = {
        inherit (mbsync) enable package;
      };
    };
  }
)
