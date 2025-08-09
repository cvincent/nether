{ name, mkFeature, ... }:
mkFeature name (
  { lib, ... }:
  {
    description = "Flatpak application packaging and distribution";

    nixos = {
      services.flatpak.enable = true;
      xdg.portal.enable = true;
      xdg.portal.config.common.default = lib.mkDefault "*";
    };
  }
)
