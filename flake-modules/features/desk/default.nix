{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    desk,
    pkgInputs,
    pkgs,
    lib,
    ...
  }:
  let
    mkAccountConfig = (
      { folderLayout, ... }@accountConfig:
      (
        rec {
          folders =
            folderLayout
            |> map (
              { refName, ... }@folder:
              {
                name = refName;
                value = folder;
              }
            )
            |> builtins.listToAttrs;

          foldersOrder = folderLayout |> map ({ localName, ... }: localName);

          totalCountFolders =
            folders
            |> lib.filterAttrs (
              k: v:
              [
                "totalCount"
                "notify"
              ]
              |> builtins.elem v.notifyLevel or null
            )
            |> lib.mapAttrsToList (
              k: v: {
                inherit (v) localName;
                refName = k;
              }
            )
            |> lib.sortOn (
              { localName, ... }: foldersOrder |> (lib.lists.findFirstIndex (n: n == localName) null)
            )
            |> map ({ refName, ... }: refName);
        }
        // accountConfig
      )
      |> lib.flip removeAttrs [ "folderLayout" ]
    );

    personalConfig = mkAccountConfig (
      lib.recursiveUpdate ((import ./personal-config.nix) nether.me.fullName) rec {
        email = pkgInputs.private-nethers.mail.personal.email;
        aliases = pkgInputs.private-nethers.mail.personal.aliases;
        imap = {
          username = email;
          password = pkgInputs.private-nethers.mail.personal.password;
        };
      }
    );

    gmailBaseConfig = mkAccountConfig (import ./gmail-base-config.nix);

    accountConfigs = {
      personal = {
        totalCountCachePath = "${desk.mailCacheBasePath}/personal";
      }
      // personalConfig;
    }
    // (
      pkgInputs.private-nethers.mail.gmails
      |> lib.mapAttrs' (
        account: accountOpts: {
          name = account;
          value = lib.recursiveUpdate gmailBaseConfig rec {
            inherit (accountOpts) email signature displayName;
            imap = {
              username = email;
              password = accountOpts.password;
            };
            totalCountCachePath = "${desk.mailCacheBasePath}/${account}";
          };
        }
      )
    );

    mailConfigFileName = baseNameOf desk.mailConfigFilePath;

    mailConfigFile =
      {
        inherit (desk) maildirBasePath filtersBasePath mailCacheBasePath;
        inherit (pkgInputs.private-nethers.mail) displayOrder;
        inherit accountConfigs;
      }
      |> builtins.toJSON
      |> builtins.toFile mailConfigFileName;

    syncEmailScripts =
      accountConfigs
      |> lib.mapAttrs' (
        account: accountConfig: {
          name = account;
          value = pkgs.writeShellApplication {
            name = "sync-email-${account}";

            runtimeInputs = [
              desk.email.aerc.package
              desk.email.imapfilter.package
              desk.email.mbsync.package
            ];

            text = ''
              imapfilter -c ~/.config/imapfilter/${account}.lua &&
              mbsync ${account} &&
              ${lib.getExe nether.software.aerc.clearCountUnreadEmailCacheScript} &&
              aerc :check-mail
            '';
          };
        }
      );

    syncEmailAllScript = pkgs.writeShellApplication {
      name = "sync-email";
      text =
        accountConfigs
        |> builtins.attrNames
        |> map (account: lib.getExe syncEmailScripts.${account})
        |> builtins.concatStringsSep " & ";
    };

    countUnreadEmailScript = pkgs.writeShellApplication {
      name = "count-unread-email";
      runtimeInputs = with pkgs; [
        nether.software.jq.package
        jo
        mblaze
      ];
      text = builtins.readFile (
        pkgs.replaceVars ./count-unread-email.bash {
          inherit (desk) mailConfigFilePath;
        }
      );
    };

    notifyMailScript = pkgs.writeShellApplication {
      name = "notify-mail";
      runtimeInputs = with pkgs; [
        nether.software.jq.package
        mblaze
        jo
      ];
      text = builtins.readFile (
        pkgs.replaceVars ./notify-mail.bash {
          inherit (desk) mailConfigFilePath;
          inherit (nether.systemNotifications) fifoPath;
        }
      );
    };

    mailWaybarModuleScript = pkgs.writeShellApplication {
      name = "waybar-module";
      runtimeInputs = with pkgs; [
        nether.software.jq.package
        jo
      ];
      text = builtins.readFile (
        pkgs.replaceVars ./waybar-module.bash {
          inherit (desk) mailConfigFilePath;
        }
      );
    };
  in
  {
    options = {
      mailConfigFilePath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.config/mail-config.json";
      };

      maildirBasePath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/mail";
      };

      filtersBasePath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.backups.mount.path}/imapfilter";
      };

      mailCacheBasePath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.cache/mail-cache";
      };

      mailWaybarModule = lib.mkOption {
        type = lib.types.package;
        default = mailWaybarModuleScript;
      };
    };

    email = {
      aerc.config = {
        inherit
          accountConfigs
          countUnreadEmailScript
          ;

        inherit (desk) mailConfigFilePath mailCacheBasePath;
      };

      imapfilter.config = {
        inherit (desk) mailConfigFilePath;

        accounts =
          accountConfigs
          |> builtins.mapAttrs (
            _: accountConfig: {
              imap = {
                inherit (accountConfig.imap)
                  host
                  port
                  username
                  password
                  ;

                ssl = accountConfig.imap.imapFilterSSL;
              };
            }
          );
      };

      imapnotify.config = { inherit accountConfigs syncEmailScripts; };
      mbsync.config = { inherit accountConfigs; };

      peroxide.config = {
        service = {
          certPem = pkgInputs.private-nethers.mail.peroxide.certPem;
          keyPem = pkgInputs.private-nethers.mail.peroxide.keyPem;
        };
      };
    };

    nixos = {
      nether.incron.userTab =
        accountConfigs
        |> lib.mapAttrsToList (
          account: accountConfig:
          (
            accountConfig.folders
            |> lib.filterAttrs (_: folder: (folder.notifyLevel or null) == "notify")
            |> lib.mapAttrsToList (
              _: folder:
              "${desk.maildirBasePath}/${account}/${folder.imapPath}/new"
              |> builtins.replaceStrings [ " " ] [ "\\ " ]
            )
          )
        )
        |> lib.flatten
        |> map (dir: "${dir} IN_MOVED_TO ${lib.getExe notifyMailScript} $@/$#")
        |> builtins.concatStringsSep "\n";

      nether.backups.paths = {
        "${desk.maildirBasePath}".deleteMissing = true;
      };
    };

    hm = {
      home.packages = [
        syncEmailAllScript
        countUnreadEmailScript
      ]
      ++ builtins.attrValues syncEmailScripts;

      xdg.configFile.${mailConfigFileName}.source = mailConfigFile;

      accounts.email = {
        inherit (desk) maildirBasePath;

        accounts =
          accountConfigs
          |> builtins.mapAttrs (
            account: accountConfig: rec {
              inherit (accountConfig) primary;
              address = accountConfig.email;
              realName = nether.me.fullName;

              userName = address;
              passwordCommand = "echo ${accountConfig.imap.password}";

              imap = { inherit (accountConfig.imap) host port tls; };
            }
          );
      };
    };
  }
)
