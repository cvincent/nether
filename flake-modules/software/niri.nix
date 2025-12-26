{ name, mkSoftware, ... }:
mkSoftware name (
  {
    config,
    niri,
    lib,
    pkgs,
    inputs',
    inputs,
    ...
  }:
  {
    nixos = {
      # programs.niri = {
      #   inherit (niri) enable package;
      # };

      programs.uwsm.waylandCompositors.niri =
        let
          niriSession = lib.getExe (
            pkgs.writeShellScriptBin "niriSession" ''
              ${lib.getExe config.programs.niri.package}
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
      # programs.niri.config = ''
      #   input {
      #     keyboard {
      #       xkb {
      #         layout ""
      #         model ""
      #         rules ""
      #         variant ""
      #       }
      #       repeat-delay 600
      #       repeat-rate 25
      #       track-layout "global"
      #     }
      #     touchpad {
      #       tap
      #       natural-scroll
      #     }
      #     mouse {
      #       natural-scroll
      #       accel-profile "adaptive"
      #     }
      #     trackball { natural-scroll; }
      #   }
      #   output "DP-4" {
      #     focus-at-startup
      #     transform "normal"
      #     position x=2560 y=1440
      #     mode "2560x1440@143.970000"
      #     variable-refresh-rate on-demand=false
      #   }
      #   output "DP-5" {
      #     transform "normal"
      #     position x=2560 y=0
      #     mode "2560x1440@143.970000"
      #     variable-refresh-rate on-demand=false
      #   }
      #   output "DP-6" {
      #     transform "normal"
      #     position x=0 y=1440
      #     mode "2560x1440@143.970000"
      #     variable-refresh-rate on-demand=false
      #   }
      #   screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
      #   prefer-no-csd
      #   layout {
      #     gaps 16
      #     struts {
      #       left 0
      #       right 0
      #       top 0
      #       bottom 0
      #     }
      #     focus-ring { off; }
      #     border {
      #       width 4
      #       active-color "#81a1c1"
      #       inactive-color "#4c566a"
      #     }
      #     default-column-width
      #     center-focused-column "never"
      #   }
      #   cursor {
      #     xcursor-theme "Nordzy-cursors"
      #     xcursor-size 32
      #     hide-after-inactive-ms 2000
      #   }
      #   binds {
      #     Mod+B { spawn "bitwarden-fuzzel"; }
      #     Mod+Comma { consume-or-expel-window-left; }
      #     Mod+Ctrl+Shift+B { spawn "bitwarden-fuzzel-create"; }
      #     Mod+D { spawn "fuzzel" "--prompt=App ❯ "; }
      #     Mod+F { fullscreen-window; }
      #     Mod+Grave { focus-window-down-or-top; }
      #     Mod+H { focus-column-left-or-last; }
      #     Mod+I { focus-monitor-up; }
      #     Mod+J { focus-window-down-or-top; }
      #     Mod+K { focus-window-up-or-bottom; }
      #     Mod+L { focus-column-right-or-first; }
      #     Mod+Next { focus-workspace-down; }
      #     Mod+O { focus-monitor-right; }
      #     Mod+Period { consume-or-expel-window-right; }
      #     Mod+Prior { focus-workspace-up; }
      #     Mod+Return { spawn "uwsm" "app" "--" "kitty"; }
      #     Mod+Shift+B { spawn "bitwarden-fuzzel" "--previous"; }
      #     Mod+Shift+Grave { focus-window-up-or-bottom; }
      #     Mod+Shift+H { move-column-left; }
      #     Mod+Shift+I { move-column-to-monitor-up; }
      #     Mod+Shift+J { move-window-down; }
      #     Mod+Shift+K { move-window-up; }
      #     Mod+Shift+L { move-column-right; }
      #     Mod+Shift+Next { move-column-to-workspace-down; }
      #     Mod+Shift+O { move-column-to-monitor-right; }
      #     Mod+Shift+Prior { move-column-to-workspace-up; }
      #     Mod+Shift+Q { close-window; }
      #     Mod+Shift+Space { toggle-window-floating; }
      #     Mod+Shift+U { move-column-to-monitor-down; }
      #     Mod+Shift+Y { move-column-to-monitor-left; }
      #     Mod+U { focus-monitor-down; }
      #     Mod+V { toggle-column-tabbed-display; }
      #     Mod+W { spawn "qutebrowser-fuzzel"; }
      #     Mod+WheelScrollDown cooldown-ms=250 { focus-workspace-down; }
      #     Mod+WheelScrollLeft cooldown-ms=250 { focus-column-left; }
      #     Mod+WheelScrollRight cooldown-ms=250 { focus-column-right; }
      #     Mod+WheelScrollUp cooldown-ms=250 { focus-workspace-up; }
      #     Mod+Y { focus-monitor-left; }
      #     XF86AudioLowerVolume { spawn "volumectl" "-u" "down"; }
      #     XF86AudioMute { spawn "volumectl" "toggle-mute"; }
      #     XF86AudioNext { spawn "playerctl" "next"; }
      #     XF86AudioPlay { spawn "playerctl" "play-pause"; }
      #     XF86AudioPrev { spawn "playerctl" "previous"; }
      #     XF86AudioRaiseVolume { spawn "volumectl" "-u" "up"; }
      #   }
      #   window-rule {
      #     blur {
      #       on
      #       radius 3
      #       passes 2
      #       noise 0.1
      #     }
      #   }
      #   xwayland-satellite { path "/nix/store/dqljjf1m5h6jscfgvc7q9kkn00mx0myj-xwayland-satellite-unstable-2025-08-07-e0d1dad/bin/xwayland-satellite"; }
      # '';

      # programs.niri.settings = {
      #   window-rules = [
      #     {
      #       shadow = {
      #         enable = true;
      #         color = "#ff0000";
      #       };

      #     }
      #   ];

      #   prefer-no-csd = true;

      #   xwayland-satellite = {
      #     enable = true;
      #     path = lib.getExe inputs'.niri.packages.xwayland-satellite-unstable;
      #   };

      #   input = {
      #     mouse = {
      #       accel-profile = "adaptive";
      #       natural-scroll = true;
      #     };
      #     trackball = {
      #       natural-scroll = true;
      #     };
      #     warp-mouse-to-focus = { };
      #   };

      #   cursor = {
      #     hide-after-inactive-ms = 2000;
      #   };

      #   outputs =
      #     let
      #       defaults = {
      #         mode = {
      #           width = 2560;
      #           height = 1440;
      #           refresh = 143.97;
      #         };
      #         variable-refresh-rate = true;
      #       };
      #     in
      #     {
      #       "DP-4" = {
      #         focus-at-startup = true;
      #         position = {
      #           x = 2560;
      #           y = 1440;
      #         };
      #       }
      #       // defaults;

      #       "DP-5" = {
      #         position = {
      #           x = 2560;
      #           y = 0;
      #         };
      #       }
      #       // defaults;

      #       "DP-6" = {
      #         position = {
      #           x = 0;
      #           y = 1440;
      #         };
      #       }
      #       // defaults;
      #     };

      #   binds = {
      #     "Mod+Return".action.spawn = [
      #       "uwsm"
      #       "app"
      #       "--"
      #       "kitty"
      #     ];
      #     "Mod+Shift+Q".action.close-window = { };

      #     "Mod+D".action.spawn = [
      #       "fuzzel"
      #       "--prompt=App ❯ "
      #     ];
      #     "Mod+W".action.spawn = "qutebrowser-fuzzel";
      #     "Mod+B".action.spawn = "bitwarden-fuzzel";
      #     "Mod+Shift+B".action.spawn = [
      #       "bitwarden-fuzzel"
      #       "--previous"
      #     ];
      #     "Mod+Ctrl+Shift+B".action.spawn = "bitwarden-fuzzel-create";

      #     "Mod+Shift+Space".action.toggle-window-floating = { };

      #     "Mod+V".action.toggle-column-tabbed-display = { };
      #     "Mod+Grave".action.focus-window-down-or-top = { };
      #     "Mod+Shift+Grave".action.focus-window-up-or-bottom = { };

      #     # kjhl - up down left right
      #     # These keys are dedicated to window focus
      #     "Mod+K".action.focus-window-up-or-bottom = { };
      #     "Mod+J".action.focus-window-down-or-top = { };
      #     "Mod+H".action.focus-column-left-or-last = { };
      #     "Mod+L".action.focus-column-right-or-first = { };

      #     # Shift modifier moves windows; up/down windowwise within a column;
      #     # left/right columnwise. Unfortunately you can't wrap up/down here.
      #     "Mod+Shift+K".action.move-window-up = { };
      #     "Mod+Shift+J".action.move-window-down = { };
      #     "Mod+Shift+H".action.move-column-left = { };
      #     "Mod+Shift+L".action.move-column-right = { };

      #     # uiyo - up down left right
      #     # These keys are dedicated to monitor focus. Unfortunately you cannot
      #     # wrap these.
      #     "Mod+I".action.focus-monitor-up = { };
      #     "Mod+U".action.focus-monitor-down = { };
      #     "Mod+Y".action.focus-monitor-left = { };
      #     "Mod+O".action.focus-monitor-right = { };

      #     # Shift modifier moves columns between monitors, always columnwise.
      #     "Mod+Shift+I".action.move-column-to-monitor-up = { };
      #     "Mod+Shift+U".action.move-column-to-monitor-down = { };
      #     "Mod+Shift+Y".action.move-column-to-monitor-left = { };
      #     "Mod+Shift+O".action.move-column-to-monitor-right = { };

      #     # Prior/Next (page up/down) - up down
      #     # These keys are dedicated to workspace focus. We only need two, since
      #     # workspaces are only arranged vertically. They cannot wrap, but it's
      #     # conceivable it could be done with the current state of Niri IPC.
      #     "Mod+Prior".action.focus-workspace-up = { };
      #     "Mod+Next".action.focus-workspace-down = { };

      #     # Shift modifier moves columns between workspaces, always columnwise.
      #     "Mod+Shift+Prior".action.move-column-to-workspace-up = { };
      #     "Mod+Shift+Next".action.move-column-to-workspace-down = { };

      #     # ,. - left right
      #     # These keys are dedicated to consume/expel
      #     "Mod+Period".action.consume-or-expel-window-right = { };
      #     "Mod+Comma".action.consume-or-expel-window-left = { };

      #     "Mod+WheelScrollDown" = {
      #       cooldown-ms = 250;
      #       action.focus-workspace-down = { };
      #     };
      #     "Mod+WheelScrollUp" = {
      #       cooldown-ms = 250;
      #       action.focus-workspace-up = { };
      #     };
      #     "Mod+WheelScrollRight" = {
      #       cooldown-ms = 250;
      #       action.focus-column-right = { };
      #     };
      #     "Mod+WheelScrollLeft" = {
      #       cooldown-ms = 250;
      #       action.focus-column-left = { };
      #     };

      #     "Mod+F".action.fullscreen-window = { };

      #     "XF86AudioRaiseVolume".action.spawn = [
      #       "volumectl"
      #       "-u"
      #       "up"
      #     ];
      #     "XF86AudioLowerVolume".action.spawn = [
      #       "volumectl"
      #       "-u"
      #       "down"
      #     ];
      #     "XF86AudioMute".action.spawn = [
      #       "volumectl"
      #       "toggle-mute"
      #     ];
      #     "XF86AudioPlay".action.spawn = [
      #       "playerctl"
      #       "play-pause"
      #     ];
      #     "XF86AudioNext".action.spawn = [
      #       "playerctl"
      #       "next"
      #     ];
      #     "XF86AudioPrev".action.spawn = [
      #       "playerctl"
      #       "previous"
      #     ];
      #   };
      # };
    };
  }
)
