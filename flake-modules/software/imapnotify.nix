{ name, mkSoftware, ... }:
mkSoftware name (
  {
    imapnotify,
    lib,
    pkgs,
    ...
  }:
  {
    package = pkgs.goimapnotify;

    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };

      syncEmailScripts = lib.mkOption {
        type = lib.types.attrsOf lib.types.package;
      };
    };

    hm = {
      accounts.email.accounts =
        imapnotify.accountConfigs
        |> builtins.mapAttrs (
          account: accountConfig: {
            imapnotify = {
              enable = true;

              boxes = [
                "Inbox"
                accountConfig.folders.spam.imapPath
              ];

              onNotify = lib.getExe imapnotify.syncEmailScripts.${account};
            };
          }
        );

      services.imapnotify = {
        inherit (imapnotify) enable package;
      };
    };
  }
)
