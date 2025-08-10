{ name, mkSoftware, ... }:
mkSoftware name (
  { networkmanagerapplet, lib, ... }:
  {
    options.service = {
      enable = lib.mkEnableOption "Start as systemd unit for graphical session";
      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
      };
    };

    hm = with networkmanagerapplet; {
      systemd = lib.mkIf service.enable {
        user.services.${name} = {
          Install.WantedBy = [ service.target ];
          Unit.After = [ service.target ];
          Service = {
            Type = "exec";
            ExecStart = "${package}/bin/nm-applet --indicator";
            Restart = "on-failure";
            Slice = "app-graphical.slice";
          };
        };
      };
    };
  }
)
