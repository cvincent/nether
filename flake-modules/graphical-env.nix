{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  # TODO: This module will almost certainly grow, and we'll want to break
  # things out into submodules.

  imports = [ (import ./swaylock { name = "swaylock"; }) ];

  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    let
      inherit (config.nether) graphicalEnv;
    in
    {
      options = {
        nether.graphicalEnv = {
          enable = lib.mkEnableOption "Graphical environment";

          displayManager = lib.mkOption {
            type = lib.types.enum [
              null
              "gdm"
            ];
            default = null;
          };

          compositor = lib.mkOption {
            type = lib.types.enum [
              null
              "hyprland"
            ];
            default = null;
          };

          notifications = {
            which = lib.mkOption {
              type = lib.types.enum [
                null
                "swaync"
              ];
              default = null;
            };

            libnotify.package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.libnotify;
            };

            swaync.package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.swaynotificationcenter;
            };
          };

          screenLocker = {
            which = lib.mkOption {
              type = lib.types.enum [
                null
                "swaylock"
              ];
              default = null;
            };

            swaylock.package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.swaylock;
            };
          };

          extra = {
            gnomeKeyring.enable = helpers.boolOpt true "GNOME Keyring - some apps need this to store secrets";

            gnomePolkit =
              helpers.pkgOpt pkgs.polkit_gnome true
                "GNOME Polkit - some apps need this to authenticate the user";
          };
        };
      };

      config = lib.mkIf graphicalEnv.enable {
        environment.systemPackages = lib.optional graphicalEnv.extra.gnomePolkit.enable graphicalEnv.extra.gnomePolkit.package;

        services.xserver = {
          enable = true;
          displayManager.gdm.enable = graphicalEnv.displayManager == "gdm";
        };

        services.gnome.gnome-keyring.enable = graphicalEnv.extra.gnomeKeyring.enable;

        # Uses login password to unlock the GNOME Keyring
        security.pam.services.login.enableGnomeKeyring = graphicalEnv.extra.gnomeKeyring.enable;

        security.polkit = {
          enable = graphicalEnv.extra.gnomePolkit.enable;
          adminIdentities = [ "unix-user:${config.nether.username}" ];
        };

        systemd = lib.mkIf graphicalEnv.extra.gnomePolkit.enable {
          user.services.polkit-gnome-authentication-agent-1 = {
            description = "polkit-gnome-authentication-agent-1";
            wantedBy = [ "graphical-session.target" ];
            wants = [ "graphical-session.target" ];
            after = [ "graphical-session.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${graphicalEnv.extra.gnomePolkit.package}/libexec/polkit-gnome-authentication-agent-1";
              Restart = "on-failure";
              RestartSec = 1;
              TimeoutStopSec = 10;
            };
          };
        };
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether) graphicalEnv;
    in
    {
      config = lib.mkIf graphicalEnv.enable {
        home.packages = lib.optional (
          graphicalEnv.notifications != null
        ) graphicalEnv.notifications.libnotify.package;
      };
    };
}
