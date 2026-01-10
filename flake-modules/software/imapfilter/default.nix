{ name, mkSoftware, ... }:
mkSoftware name (
  {
    imapfilter,
    lib,
    pkgs,
    nether,
    ...
  }:
  {
    package = pkgs.symlinkJoin (
      let
        luaWithPkgs = pkgs.lua.withPackages (ps: [
          ps.penlight
          ps.cjson
        ]);

        luaPath = pkgs.lua.pkgs.luaLib.genLuaPathAbsStr luaWithPkgs;
        luaCPath = pkgs.lua.pkgs.luaLib.genLuaCPathAbsStr luaWithPkgs;
      in
      {
        name = "imapfilter";
        paths = [ pkgs.imapfilter ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/imapfilter \
          --set LUA_PATH "${luaPath}" \
          --set LUA_CPATH "${luaCPath}"
        '';
      }
    );

    options = {
      accounts = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              imap = {
                host = lib.mkOption { type = lib.types.str; };
                port = lib.mkOption { type = lib.types.port; };
                username = lib.mkOption { type = lib.types.str; };
                password = lib.mkOption { type = lib.types.str; };

                ssl = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
              };
            };
          }
        );
      };

      mailConfigFilePath = lib.mkOption { type = lib.types.str; };

      fileEmailScripts = lib.mkOption {
        type = lib.types.attrsOf lib.types.package;
        default =
          imapfilter.accounts
          |> lib.mapAttrs' (
            account: accountConfig: {
              name = account;
              value = pkgs.writeShellApplication {
                name = "file-emails-${account}";

                runtimeInputs = [
                  nether.desk.email.aerc.package
                  nether.graphicalEnv.notifications.libnotify.package
                  pkgs.mblaze
                  pkgs.gnugrep
                ];

                text = builtins.readFile (
                  pkgs.replaceVars ./file-emails.bash {
                    inherit account;
                    inherit (imapfilter) mailConfigFilePath;
                  }
                );
              };
            }
          );
      };
    };

    hm = {
      home.packages = [ imapfilter.package ];

      xdg.configFile =
        imapfilter.accounts
        |> lib.mapAttrs' (
          account: accountOpts: {
            name = "imapfilter/${account}.lua";

            value.text =
              let
                ssl = if accountOpts.imap.ssl != null then ''ssl = "${accountOpts.imap.ssl}"'' else "";
              in
              (lib.concatStringsSep "\n" [
                ''
                  local account = IMAP {
                    server = "${accountOpts.imap.host}",
                    port = ${toString accountOpts.imap.port},
                    username = "${accountOpts.imap.username}",
                    password = "${accountOpts.imap.password}",
                    ${ssl}
                  };
                ''
                (lib.readFile (
                  pkgs.replaceVars ./imapfilter.lua {
                    inherit account;
                    inherit (imapfilter) mailConfigFilePath;
                  }
                ))
              ]);
          }
        );
    };
  }
)
