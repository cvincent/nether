applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [
    "hyprland"
    "kitty"
    "neovim"
    "swaylock"
    "swaync"
    "waybar"
  ];
}
