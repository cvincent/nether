{ name, mkSoftware, ... }:
mkSoftware name (
  { blueman, lib, ... }:
  {
    options.trayService = {
      enable = lib.mkEnableOption "Start as systemd unit for graphical session";
      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
      };
    };

    nixos.services.blueman.enable = true;

    hm = with blueman; {
      systemd = lib.mkIf trayService.enable {
        user.services."${name}-tray" = {
          Install.WantedBy = [ trayService.target ];
          Unit.After = [ trayService.target ];
          Service = {
            Type = "exec";
            ExecStart = "${package}/bin/blueman-tray";
            Restart = "on-failure";
            Slice = "app-graphical.slice";
          };
        };
      };
    };
  }
)
