applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [
    "hyprland"
    "kitty"
    "neovim"
    "qutebrowser"
    "swaylock"
    "swaync"
    "waybar"
  ];
}
