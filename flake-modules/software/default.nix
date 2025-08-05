applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [
    "hyprland"
    "kitty"
    "swaylock"
    "swaync"
    "waybar"
  ];
}
