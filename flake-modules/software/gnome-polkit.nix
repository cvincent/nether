{ name, mkSoftware, ... }:
mkSoftware name (
  {
    nether,
    gnome-polkit,
    pkgs,
    ...
  }:
  {
    package = pkgs.polkit_gnome;

    nixos = {
      environment.systemPackages = [ gnome-polkit.package ];

      security.polkit = {
        enable = true;
        adminIdentities = [ "unix-user:${nether.username}" ];
      };

      systemd = {
        user.services.polkit-gnome-authentication-agent-1 = {
          description = "polkit-gnome-authentication-agent-1";
          wantedBy = [ "graphical.target" ];
          wants = [ "graphical.target" ];
          after = [ "graphical.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${gnome-polkit.package}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };
      };
    };
  }
)
