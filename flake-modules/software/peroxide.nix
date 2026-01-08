{ name, mkSoftware, ... }:
mkSoftware name (
  {
    peroxide,
    lib,
    self',
    pkgs,
    nether,
    ...
  }:
  let
    yamlFormat = pkgs.formats.yaml { };
  in
  {
    # Largely adapted from https://github.com/NixOS/nixpkgs/blob/7fb4aae81f3afc1336a88b0b3f1fa8518f64968e/nixos/modules/services/networking/peroxide.nix

    options.service = {
      certPem = lib.mkOption { type = lib.types.str; };
      keyPem = lib.mkOption { type = lib.types.str; };

      logPath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.local/state/peroxide/service.log";
      };

      logLevel = lib.mkOption {
        type = lib.types.enum [
          "Panic"
          "Fatal"
          "Error"
          "Warning"
          "Info"
          "Debug"
          "Trace"
        ];
        default = "Warning";
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = yamlFormat.type;

          options = {
            UserPortImap = lib.mkOption {
              type = lib.types.port;
              default = 1143;
            };

            UserPortSmtp = lib.mkOption {
              type = lib.types.port;
              default = 1025;
            };

            ServerAddress = lib.mkOption {
              type = lib.types.str;
              default = "[::0]";
            };

            CacheDir = lib.mkOption {
              type = lib.types.str;
              default = "${nether.homeDirectory}/.cache/peroxide";
            };

            CookieJar = lib.mkOption {
              type = lib.types.str;
              default = "${nether.homeDirectory}/.local/state/peroxide/cookies.json";
            };

            CredentialsStore = lib.mkOption {
              type = lib.types.str;
              default = "${nether.homeDirectory}/.local/state/peroxide/credentials.json";
            };

            X509Key = lib.mkOption {
              type = lib.types.str;
              default = "${nether.homeDirectory}/.config/peroxide/key.pem";
            };

            X509Cert = lib.mkOption {
              type = lib.types.str;
              default = "${nether.homeDirectory}/.config/peroxide/cert.pem";
            };
          };
        };

        default = { };
      };
    };

    nixos = {
      nether.backups.paths = {
        "${peroxide.service.settings.CacheDir}".deleteMissing = true;
        "${peroxide.service.settings.CookieJar}" = { };
        "${peroxide.service.settings.CredentialsStore}" = { };
      };

      services.logrotate.settings.peroxide = {
        files = peroxide.service.logPath;
        rotate = 31;
        frequency = "daily";
        compress = true;
        delaycompress = true;
        missingok = true;
        notifempty = true;
      };
    };

    hm = {
      home.packages = [ self'.packages.peroxide ];

      xdg.configFile."peroxide/config.yml".source =
        yamlFormat.generate "config.yml" peroxide.service.settings;

      home.file = {
        "${peroxide.service.settings.X509Cert}".text = peroxide.service.certPem;
        "${peroxide.service.settings.X509Key}".text = peroxide.service.keyPem;
      };

      systemd = lib.mkIf peroxide.enable {
        user.services.${name} = {
          Install.WantedBy = [ "graphical-session.target" ];
          Unit.After = [ "graphical-session.target" ];
          Service = {
            Type = "simple";
            ExecStart = "${self'.packages.peroxide}/bin/peroxide -log-file=${peroxide.service.logPath} -log-level=${peroxide.service.logLevel} -config=${nether.homeDirectory}/.config/peroxide/config.yml";
            ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          };
        };
      };
    };
  }
)
