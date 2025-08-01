applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [
    "fish"
    "hyprland"
    "kitty"
    "neovim"
    "qutebrowser"
    "swaylock"
    "swaync"
    "waybar"
  ];
}
