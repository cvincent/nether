{ name, mkSoftware, ... }:
mkSoftware name (
  { wl-clip-persist, lib, ... }:
  {
    options.service = {
      enable = lib.mkEnableOption "Start as systemd unit for graphical session";
      target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
      };
    };

    hm = with wl-clip-persist; {
      systemd = lib.mkIf service.enable {
        user.services.${name} = {
          Install.WantedBy = [ service.target ];
          Unit.After = [ service.target ];
          Service = {
            Type = "exec";
            ExecStart = "${package}/bin/wl-clip-persist --clipboard regular";
            Restart = "on-failure";
            Slice = "background-graphical.slice";
          };
        };
      };
    };
  }
)
