{
  name,
  mkFeature,
  mkSoftwareChoice,
  ...
}:
mkFeature name (
  {
    options,
    graphicalEnv,
    lib,
    pkgs,
    helpers,
    ...
  }:
  let
    mkSoftwareChoiceArgs = {
      inherit name;
      thisConfig = graphicalEnv;
    };
  in
  { }
  |> lib.recursiveUpdate (
    mkSoftwareChoice (mkSoftwareChoiceArgs // { namespace = "displayManager"; }) {
      gdm.package = null;
      lightdm.package = null;
    }
  )
  |> lib.recursiveUpdate (
    mkSoftwareChoice (mkSoftwareChoiceArgs // { namespace = "compositor"; }) {
      hyprland = { };
    }
  )
  |> lib.recursiveUpdate (
    mkSoftwareChoice (mkSoftwareChoiceArgs // { namespace = "launcher"; }) {
      fuzzel.config.settings = lib.mkOptionDefault {
        main.output = graphicalEnv.primaryDisplay;
      };
    }
  )
  |> lib.recursiveUpdate (
    mkSoftwareChoice (mkSoftwareChoiceArgs // { namespace = "bar"; }) {
      waybar = { };
    }
  )
  |> lib.recursiveUpdate (
    mkSoftwareChoice (mkSoftwareChoiceArgs // { namespace = "notifications"; }) {
      swaync = { };

      libnotify.choice = false;
      nixos.nether.graphicalEnv.notifications.libnotify.enable =
        graphicalEnv.notifications.default.which != null;
    }
  )
  |> lib.recursiveUpdate (
    mkSoftwareChoice (mkSoftwareChoiceArgs // { namespace = "screenLocker"; }) {
      swaylock = { };

      swayidle = {
        choice = false;

        options = {
          lockSeconds = lib.mkOption {
            type = lib.types.int;
            default = 3600; # 1 hour
          };

          sleep = {
            enable = (lib.mkEnableOption "sleep") // {
              default = true;
            };
            seconds = lib.mkOption {
              type = lib.types.int;
              default = 4200; # 1 hour, 10 minutes
            };
          };
        };

        config =
          with graphicalEnv;
          let
            sleepCommand = compositor.${compositor.default.which}.sleepCommand or null;
            resumeCommand = compositor.${compositor.default.which}.resumeCommand or null;
          in
          {
            timeouts = [
              {
                timeout = screenLocker.swayidle.lockSeconds;
                command = screenLocker.default.path;
              }
            ]
            ++ (lib.optional
              (screenLocker.swayidle.sleep.enable && sleepCommand != null && resumeCommand != null)
              {
                timeout = screenLocker.swayidle.sleep.seconds;
                command = sleepCommand;
                inherit resumeCommand;
              }
            );

            events = [
              {
                event = "before-sleep";
                command = screenLocker.default.path;
              }
            ];
          };
      };

      nixos.nether.graphicalEnv.screenLocker.swayidle.enable =
        graphicalEnv.screenLocker.default.which != null;
    }
  )
  |> lib.recursiveUpdate (
    mkSoftwareChoice (mkSoftwareChoiceArgs // { namespace = "wallpapers"; }) {
      swww = { };
    }
  )
  |> lib.recursiveUpdate {
    options.primaryDisplay = lib.mkOption {
      type = lib.types.str;
      default = "DP-1";
    };

    clipboardSupport = {
      wl-clipboard = { };
      wl-clip-persist = { };
      cliphist = { };
    };

    extra = {
      avizo = { };
      gnome-keyring = { };
      gnome-polkit = { };

      nwg-displays = { };

      nixos.nether.graphicalEnv.extra.nwg-displays =
        let
          forCompositors =
            graphicalEnv.compositor
            |> lib.filterAttrs (_: opts: opts ? enable && opts.enable)
            |> lib.mapAttrsToList (name: _: name);
        in
        {
          enable = lib.mkOptionDefault (
            with builtins;
            any (compositor: elem compositor forCompositors) [
              "hyprland"
              "sway"
            ]
          );

          inherit forCompositors;
        };
    };

    screenshots = {
      grim = { };
      slurp = { };
      swappy = { };
      flameshot = { };
    };
  }
)
