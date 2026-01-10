{ name, mkFeature, ... }:
mkFeature name (
  {
    systemNotifications,
    lib,
    pkgs,
    nether,
    ...
  }:
  {
    options = {
      fifoPath = lib.mkOption {
        type = lib.types.str;
        default = "${nether.homeDirectory}/.local/state/.system-notifications";
      };
    };

    hm =
      let
        fifoLoop = pkgs.writeShellApplication {
          name = "system-notifications-fifo-loop";
          runtimeInputs = with pkgs; [
            nether.graphicalEnv.notifications.libnotify.package
            nether.software.jq.package
            coreutils
            dbus
            jo
          ];
          text = builtins.readFile (
            pkgs.replaceVars ./fifo-loop.bash {
              inherit (systemNotifications) fifoPath;
            }
          );
        };
      in
      {
        systemd.user.services.${name} =
          let
            target = "graphical-session.target";
          in
          {
            Install.WantedBy = [ target ];
            Unit.After = [ target ];
            Service = {
              Type = "simple";
              ExecStart = lib.getExe fifoLoop;
              Restart = "on-failure";
            };
          };
      };
  }
)
