{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs, system }:
    { config, inputs, ... }:
    {
      config =
        lib.mkIf
          (config.nether.graphicalEnv.enable && config.nether.graphicalEnv.compositor.which == "hyprland")
          {
            # Ensure the /tmp/hypr symlink exists to continue using older versions of
            # Waybar and Pyprland that don't require me to fix their configs, until I'm
            # ready and/or replace Waybar with Astal or something
            environment.systemPackages = [
              (pkgs.runCommand "tmp-hypr-symlink" { } ''
                ln -s /run/user/1000/hypr /tmp/hypr
                mkdir $out
              '')
            ];

            # Seems to me I'm always rebuilding binaries, maybe due to pinning the
            # Hyprland version in my flake. Either way, declaring this doesn't hurt
            nix.settings = {
              substituters = [ "https://hyprland.cachix.org" ];
              trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
            };

            programs.hyprland = {
              enable = true;
              package = config.nether.graphicalEnv.compositor.hyprland.package;
            };

          environment.sessionVariables = ({
            # Recommended env vars from the Hyprland wiki
            GDK_BACKEND = "wayland,x11";
            QT_QPA_PLATFORM = "wayland;xcb";
            SDL_VIDEODRIVER = "wayland";
            CLUTTER_BACKEND = "wayland";
            XDG_CURRENT_DESKTOP = "Hyprland";
            XDG_SESSION_TYPE = "wayland";
            XDG_SESSION_DESKTOP = "Hyprland";
            QT_AUTO_SCREEN_SCALE_FACTOR = "1";
            QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
            # This is no longer a hard requirement in latest Hyprland or probably
            # Wayland more generally (fix was pulled from a wlroots patch), but I tried
            # without it and found the cursor quite stuttery still, including with
            # `allow_dumb_copy` in the Hyprland config
            WLR_NO_HARDWARE_CURSORS = "1";
            # This may help with laggy cursor? It's still laggy though
            OGL_DEDICATED_HW_STATE_PER_CONTEXT = "ENABLE_ROBUST";
            # Launch apps in native Wayland (not XWayland) by default
            NIXOS_OZONE_WL = "1";
            # Would be required for tearing, which we don't really need as we don't
            # game on here these days
            # WLR_DRM_NO_ATOMIC = "1";
          } // (lib.mkIf config.nether.hardware.nvidia.enable {
              # Remove if Firefox crashes:
              GBM_BACKEND = "nvidia-drm";
              # Remove if issues with Discord windows or Zoom screensharing:
              __GLX_VENDOR_LIBRARY_NAME = "nvidia";

              AQ_DRM_DEVICES = "/dev/dri/card1";
            }));

            hardware.graphics = {
              package = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system}.mesa.drivers;
              package32 = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system}.pkgsi686Linux.mesa.drivers;
            };
          };
    }
  );

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, helpers, ... }:
    let
      scratchpads = import ./scratchpads.nix;
      scratchpads-classes = builtins.concatStringsSep "," (
        map ({ class, ... }: "\"${class}\"") scratchpads
      );
    in
    {
      config =
        lib.mkIf
          (osConfig.nether.graphicalEnv.enable && osConfig.nether.graphicalEnv.compositor.which == "hyprland")
          {
            home = {
              packages = with pkgs; [
                pyprland
                hyprpicker

                (pkgs.writeShellScriptBin "hide-scratchpad" ''
                  current_scratch=$(hyprctl clients -j | jq -r 'map({class, at}) | map(select(.class | IN(${scratchpads-classes}))) | map(select(.at[1] > -400)) | .[].class')

                  if [ "$current_scratch" ]; then
                  pypr hide $current_scratch
                  fi
                '')
              ];

              file = {
                "./.config/hypr/hyprland.conf".source = helpers.directSymlink ./configs/hyprland.conf;
                "./.config/hypr/monitors.conf".source = helpers.directSymlink ./configs/monitors.conf;
                "./.config/hypr/workspaces.conf".source = helpers.directSymlink ./configs/workspaces.conf;
                "./.config/hypr/shaders".source = helpers.directSymlink ./configs/shaders;

                "./.config/hypr/pyprland.toml".text = builtins.concatStringsSep "\n" (
                  [
                    ''
                      [pyprland]
                      plugins = ["scratchpads", "magnify"]
                    ''
                  ]
                  ++ map (
                    {
                      class,
                      name ? class,
                      command,
                      ...
                    }:
                    ''
                      [scratchpads.${name}]
                      command = "${command}"
                      animation = "fromTop"
                      unfocus = "hide"
                      margin = 50
                      offset = "500%"
                      force_monitor = "DP-1"
                      exclude = "*"
                    ''
                  ) scratchpads
                );

                "./.config/hypr/scratchpads.conf".text = builtins.concatStringsSep "\n" (
                  map (
                    {
                      class,
                      name ? class,
                      binding,
                      size ? "60% 60%",
                      ...
                    }:
                    ''
                      bind = ${binding}, exec, pypr toggle ${name}
                      windowrule = float, ^(${class})$
                      windowrule = size ${size}, ^(${class})$
                      windowrule = move 30% -1000%, ^(${class})$
                    ''
                  ) scratchpads
                );
              };
            };

            programs.fish.functions = {
              reload-scratchpads = builtins.concatStringsSep "\n" (
                (map ({ class, ... }: "pkill --full ${class}") scratchpads)
                ++ [
                  "pkill --full pyprland"
                  "rm /run/user/1000/hypr/*/.pyprland.sock"
                  "pypr & disown"
                ]
              );
            };
          };
    }
  );
}
