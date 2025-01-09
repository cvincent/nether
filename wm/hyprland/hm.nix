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
  nixpkgs.overlays = [
    (self: super: {
      # Bring in latest which is patched to actually launch
      hyprpicker-latest = super.hyprpicker.overrideAttrs (old: {
        src = super.fetchFromGitHub {
          owner = "hyprwm";
          repo = "hyprpicker";
          rev = "b6130e3901ed5c6d423f168705929e555608d870";
          sha256 = "sha256-x+6yy526dR75HBmTJvbrzN+sXINVL26yN5TY75Dgpwk=";
        };
      });
    })
  ];

  imports = [ ../wayland/hm.nix ];

  home = {
    packages = with pkgs; [
      pyprland
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
            bind = ${binding}, focusmonitor, DP-1
            bind = ${binding}, exec, pypr toggle ${name}
            windowrule = float, ^(${class})$
            windowrule = size ${size}, ^(${class})$
            windowrule = move 30% -200%, ^(${class})$
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
        "pypr & disown"
      ]
    );
  };
}
