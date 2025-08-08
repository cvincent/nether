{ name, mkSoftware, ... }:
mkSoftware name (
  { nwg-displays, lib, ... }:
  {
    options.forCompositors = lib.mkOption {
      type = with lib.types; listOf str;
      default = null;
    };

    nixos.nether.software.wlr-randr.enable = builtins.elem "hyprland" nwg-displays.forCompositors;
    hm.home.packages = [ nwg-displays.package ];
  }
)
