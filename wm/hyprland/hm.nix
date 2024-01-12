{ config, pkgs, utils, ... }:

{
  nixpkgs.overlays = [(self: super: {
    # Bring in latest which is patched to actually launch
    hyprpicker-latest = super.hyprpicker.overrideAttrs (old: {
      src = super.fetchFromGitHub {
        owner = "hyprwm";
        repo = "hyprpicker";
        rev = "b6130e3901ed5c6d423f168705929e555608d870";
        sha256 = "sha256-x+6yy526dR75HBmTJvbrzN+sXINVL26yN5TY75Dgpwk=";
      };
    });
  })];

  imports = [ ../wayland/hm.nix ];

  home = let
    scratchpads = import ./scratchpads.nix;
    scratchpads-classes = builtins.concatStringsSep "," (map ({ class, ... }: "\"${class}\"") scratchpads);
  in
  {
    packages = with pkgs; [
      hyprpaper
      pyprland
      hyprpicker-latest

      (pkgs.writeShellScriptBin "switch-scratchpad" ''
        current_scratch=$(hyprctl clients -j | jq -r 'map({class, at}) | map(select(.class | IN(${scratchpads-classes}))) | map(select(.at[1] > -400)) | .[].class')

        if [ "$current_scratch" ]; then
          pypr hide $current_scratch
        fi

        if [ "$current_scratch" != $1 ]; then
          pypr show $1
          sleep 0.2
          hyprctl dispatch alterzorder top, $1
        fi
      '')
    ];

    file = {
      "./.config/hypr/hyprland.conf".source = utils.directSymlink "wm/hyprland/configs/hyprland.conf";
      "./.config/hypr/hyprpaper.conf".source = utils.directSymlink "wm/hyprland/configs/hyprpaper.conf";
      "./.config/hypr/monitors.conf".source = utils.directSymlink "wm/hyprland/configs/monitors.conf";
      "./.config/hypr/workspaces.conf".source = utils.directSymlink "wm/hyprland/configs/workspaces.conf";
      "./.config/hypr/shaders".source = utils.directSymlink "wm/hyprland/configs/shaders";

      "./.config/hypr/pyprland.toml".text = builtins.concatStringsSep "\n" (
        [
          ''
          [pyprland]
          plugins = ["scratchpads", "magnify"]
          ''
        ] ++
        map ({ class, command, ... }: ''
          [scratchpads.${class}]
          command = "${command}"
          animation = "fromTop"
          unfocus = "hide"
          margin = 50
        '') scratchpads
      );

      "./.config/hypr/scratchpads.conf".text = builtins.concatStringsSep "\n" (
        map ({ class, binding, size ? "60% 60%", ... }: ''
          bind = ${binding}, exec, switch-scratchpad ${class}
          windowrule = float, ^(${class})$
          windowrule = size ${size}, ^(${class})$
          windowrule = move 30% -200%, ^(${class})$
        '') scratchpads
      );
    };
  };
}
