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

  imports = [
    (import ./swaylock { name = "swaylock"; })
    (import ./swaync { name = "swaync"; })
    (import ./waybar { name = "waybar"; })
  ];

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

          # TODO: displayManager, compositor, and pickers in other modules
          # should follow the convention of other pickers in this module
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

          bar = {
            which = lib.mkOption {
              type = lib.types.enum [
                null
                "waybar"
              ];
              default = null;
            };

            waybar.package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.waybar;
            };
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

          wallpapers = {
            which = lib.mkOption {
              type = lib.types.enum [
                null
                "swww"
              ];
              default = null;
            };

            swww.package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.swww;
            };
          };

          extra = {
            clipboardSupport =
              let
                enabled = graphicalEnv.extra.clipboardSupport.enable;
              in
              {
                enable = helpers.boolOpt true "Clipboard support - utilities for working with and enhancing the clipboard";
                wlClipboard = helpers.pkgOpt pkgs.wl-clipboard enabled "wl-clipboard - CLI for the clipboard";
                wlClipPersist =
                  helpers.pkgOpt pkgs.wl-clip-persist enabled
                    "wl-clip-persist - Persist the clipboard";
                cliphist = helpers.pkgOpt pkgs.cliphist enabled "cliphist - Clipboard history";
              };

            displaySettings =
              let
                enabled = graphicalEnv.extra.displaySettings.enable;
              in
              {
                enable = helpers.boolOpt true "Utilities for manipulating display settings";
                nwgDisplays = helpers.pkgOpt pkgs.nwg-displays enabled "nwg-displays - GUI for display settings";
                wlrRandr =
                  helpers.pkgOpt pkgs.wlr-randr enabled
                    "wlr-randr - CLI for display settings; dependency of nwg-displays";
              };

            gnomeKeyring.enable = helpers.boolOpt true "GNOME Keyring - some apps need this to store secrets";

            gnomePolkit =
              helpers.pkgOpt pkgs.polkit_gnome true
                "GNOME Polkit - some apps need this to authenticate the user";

            screenshotSupport =
              let
                enabled = graphicalEnv.extra.screenshotSupport.enable;
              in
              {
                enable = helpers.boolOpt true "Screenshot support - utilities for creating and editing screenshots";
                grim = helpers.pkgOpt pkgs.grim enabled "grim - CLI for taking screenshots";
                slurp = helpers.pkgOpt pkgs.slurp enabled "slurp - utility for selecting regions of the screen";
                swappy =
                  helpers.pkgOpt pkgs.swappy enabled
                    "swappy - app for editing screenshots after they are taken";
              };

            # TODO: This should probably be grouped with screenLocker settings
            swayIdle = helpers.pkgOpt pkgs.swayidle true "swayidle - Idle timer and command launcher";
          };
        };
      };

      config = lib.mkIf graphicalEnv.enable {
        # TODO: Extract all this, and _maybe_ also the home.packages below.
        # We'll want to figure out our conventions on nesting and directories.
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
        home.packages =
          [ ]
          ++ lib.optional (graphicalEnv.notifications != null) graphicalEnv.notifications.libnotify.package
          ++ lib.optional (graphicalEnv.wallpapers == "swww") graphicalEnv.wallpapers.swww.package
          ++ helpers.pkgOptPkg graphicalEnv.extra.clipboardSupport.wlClipboard
          ++ helpers.pkgOptPkg graphicalEnv.extra.clipboardSupport.wlClipPersist
          ++ helpers.pkgOptPkg graphicalEnv.extra.clipboardSupport.cliphist
          ++ helpers.pkgOptPkg graphicalEnv.extra.displaySettings.nwgDisplays
          ++ helpers.pkgOptPkg graphicalEnv.extra.displaySettings.wlrRandr
          ++ helpers.pkgOptPkg graphicalEnv.extra.screenshotSupport.grim
          ++ helpers.pkgOptPkg graphicalEnv.extra.screenshotSupport.slurp
          ++ helpers.pkgOptPkg graphicalEnv.extra.screenshotSupport.swappy
          ++ helpers.pkgOptPkg graphicalEnv.extra.swayIdle;
      };
    };
}
