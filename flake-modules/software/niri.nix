{ name, mkSoftware, ... }:
mkSoftware name (
  {
    config,
    niri,
    lib,
    pkgs,
    inputs',
    ...
  }:
  {
    nixos = {
      programs.niri = {
        inherit (niri) enable package;
      };

      programs.uwsm.waylandCompositors.niri =
        let
          niriSession = lib.getExe (
            pkgs.writeShellScriptBin "niriSession" ''
              ${lib.getExe config.programs.niri.package} --session
            ''
          );
        in
        {
          prettyName = "niri";
          comment = "niri comopsitor managed by UWSM";
          binPath = niriSession;
        };
    };

    hm = {
      programs.niri.settings = {
        xwayland-satellite = {
          enable = true;
          path = lib.getExe inputs'.niri.packages.xwayland-satellite-unstable;
        };

        input = {
          mod-key = "Super";
        };

        binds = {
          "Mod+Return".action.spawn = [
            "uwsm"
            "app"
            "--"
            "kitty"
          ];
          "Mod+Shift+Q".action.close-window = { };

          "Mod+D".action.spawn = [
            "fuzzel"
            "--prompt=App ❯ "
          ];
          "Mod+W".action.spawn = "qutebrowser-fuzzel";
          "Mod+B".action.spawn = "bitwarden-fuzzel";
          "Mod+Shift+B".action.spawn = [
            "bitwarden-fuzzel"
            "--previous"
          ];
          "Mod+Ctrl+Shift+B".action.spawn = "bitwarden-fuzzel-create";

          "Mod+Shift+Space".action.toggle-window-floating = { };
          "Mod+V".action.toggle-column-tabbed-display = { };

          "Mod+K".action.focus-window-or-workspace-up = { };
          "Mod+L".action.focus-column-right-or-first = { };
          "Mod+H".action.focus-column-left-or-last = { };
          "Mod+J".action.focus-window-or-workspace-down = { };

          "Mod+F".action.fullscreen-window = { };

          "XF86AudioRaiseVolume".action.spawn = [
            "volumectl"
            "-u"
            "up"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "volumectl"
            "-u"
            "down"
          ];
          "XF86AudioMute".action.spawn = [
            "volumectl"
            "toggle-mute"
          ];
          "XF86AudioPlay".action.spawn = [
            "playerctl"
            "play-pause"
          ];
          "XF86AudioNext".action.spawn = [
            "playerctl"
            "next"
          ];
          "XF86AudioPrev".action.spawn = [
            "playerctl"
            "previous"
          ];
        };
      };
    };
  }
)
