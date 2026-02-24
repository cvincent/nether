{ name, mkSoftware, ... }:
mkSoftware name (
  {
    msmtp,
    lib,
    pkgs,
    nether,
    hmConfig,
    helpers,
    self',
    ...
  }:
  {
    options = {
      accountConfigs = lib.mkOption {
        type = lib.types.attrsOf lib.types.attrs;
      };

      msmtpqFifoPath = lib.mkOption {
        type = lib.types.str;
      };

      scripts =
        let
          msmtpConfigPath = "${nether.homeDirectory}/.config/msmtp/config";
        in
        builtins.listToAttrs [
          (helpers.mkScript ./. "msmtpq-fifo-loop" {
            runtimeInputs = with pkgs; [
              coreutils
              self'.packages.mime-email
              nether.software.jq.package
              nether.software.jq.tools.json_to_assoc
            ];

            replaceVars = {
              inherit msmtpConfigPath;
              inherit (msmtp) msmtpqFifoPath;
            };
          })
        ];
    };

    hm = {
      programs.msmtp.enable = true;

      accounts.email.accounts =
        msmtp.accountConfigs
        |> builtins.mapAttrs (
          account: accountConfig: {
            msmtp = {
              enable = true;
              extraConfig.auth = if accountConfig.smtp.scheme == "smtp+insecure" then "plain" else "on";
            };
          }
        );

      systemd =
        let
          msmtpqEnv = [
            "MSMTPQ_Q=${hmConfig.home.sessionVariables.MSMTPQ_Q}"
            "MSMTPQ_LOG=${hmConfig.home.sessionVariables.MSMTPQ_LOG}"
          ];
        in
        {
          user.services.msmtpq = {
            Unit.Description = "Flush msmtp mail queue";
            Install.WantedBy = [ "default.target" ];
            Service = {
              Environment = msmtpqEnv;
              ExecStart = "${pkgs.msmtp.scripts}/bin/msmtp-queue -r";
              Type = "oneshot";
            };
          };

          user.timers.msmtpq = {
            Install.WantedBy = [ "timers.target" ];
            Timer.OnCalendar = "*:*:00";
            Timer.AccuracySec = "1s";
          };

          user.services.msmtpq-fifo-loop = {
            Install.WantedBy = [ "default.target" ];
            Service = {
              Environment = msmtpqEnv;
              Type = "simple";
              ExecStart = lib.getExe msmtp.scripts.msmtpq-fifo-loop;
              Restart = "on-failure";
            };
          };
        };
    };
  }
)
