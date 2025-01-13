{
  pkgs,
  utils,
  ...
}:
let
  scratchpads = import ./scratchpads.nix;
  scratchpads-classes = builtins.concatStringsSep "," (
    map ({ class, ... }: "\"${class}\"") scratchpads
  );
in
{
  imports = [ ../wayland/hm.nix ];

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
      "./.config/hypr/hyprland.conf".source = utils.directSymlink "wm/hyprland/configs/hyprland.conf";
      "./.config/hypr/monitors.conf".source = utils.directSymlink "wm/hyprland/configs/monitors.conf";
      "./.config/hypr/workspaces.conf".source = utils.directSymlink "wm/hyprland/configs/workspaces.conf";
      "./.config/hypr/shaders".source = utils.directSymlink "wm/hyprland/configs/shaders";

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
}
