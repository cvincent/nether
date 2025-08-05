applyArgs@{ mkModuleDir, ... }:
moduleArgs:
mkModuleDir ./. {
  inherit applyArgs moduleArgs;
  exclude = [
    "kitty"
    "swaylock"
    "swaync"
    "waybar"
  ];
}
